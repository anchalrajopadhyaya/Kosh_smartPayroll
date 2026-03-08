import 'package:flutter/material.dart';
import 'package:payroll/frontend/employee/timerequest.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:payroll/frontend/widgets/attendance_details.dart';

class AttendanceContent extends StatefulWidget {
  final Map<String, dynamic> userData;
  const AttendanceContent({super.key, required this.userData});

  @override
  State<AttendanceContent> createState() => _AttendanceContentState();
}

class _AttendanceContentState extends State<AttendanceContent> {
  List<dynamic> _attendanceHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceHistory();
  }

  Future<void> _fetchAttendanceHistory() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:3000/api/attendance/history/${widget.userData['id']}',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _attendanceHistory = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw 'Failed to load history';
      }
    } catch (e) {
      print('Error fetching attendance: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Attendance History",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchAttendanceHistory();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF188984)),
              )
              : RefreshIndicator(
                onRefresh: _fetchAttendanceHistory,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SummaryCard(
                            label: "Present",
                            count: _attendanceHistory.length,
                            color: Colors.green,
                          ),
                          const SummaryCard(
                            label: "Absent",
                            count: 0,
                            color: Colors.red,
                          ),
                          const SummaryCard(
                            label: "Leave",
                            count: 0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Recent Logs",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (_attendanceHistory.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text("No attendance records found."),
                          ),
                        )
                      else
                        ..._attendanceHistory.map((item) {
                          // Format the date if it's from DB
                          DateTime fullDate = DateTime.parse(item['date']);
                          String formattedDate = DateFormat(
                            'EEE, MMM d',
                          ).format(fullDate);

                          String inTime = item['punch_in_time'] ?? '--:--';
                          String outTime = item['punch_out_time'] ?? '--:--';

                          return AttendanceCard(
                            date: formattedDate,
                            status:
                                item['punch_in_distance'] != null
                                    ? 'Present'
                                    : 'Logged',
                            hours:
                                item['punch_in_location_name'] ??
                                'Address not found',
                            checkIn: inTime,
                            checkOut: outTime,
                            onTap: () => showDetailsDialog(context, item),
                          );
                        }).toList(),

                      const SizedBox(height: 24),

                      // Pending Requests Section
                      const Text(
                        "Actions",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TimeRequestPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF188984),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Apply Time Request",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const SummaryCard({
    super.key,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: color.withOpacity(0.2),
            child: CircleAvatar(radius: 6, backgroundColor: color),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final String date;
  final String status;
  final String hours;
  final String checkIn;
  final String checkOut;
  final VoidCallback onTap;

  const AttendanceCard({
    super.key,
    required this.date,
    required this.status,
    required this.hours,
    required this.checkIn,
    required this.checkOut,
    required this.onTap,
  });

  Color getStatusColor() {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Leave':
        return Colors.blue;
      default:
        return Color(0xFF188984);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: getStatusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                hours,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Check In/Out
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Punch In",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          checkIn,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Punch Out",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          checkOut,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF188984),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
