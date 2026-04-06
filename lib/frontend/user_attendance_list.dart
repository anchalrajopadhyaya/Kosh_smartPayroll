import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:payroll/frontend/widgets/attendance_details.dart';
import 'package:payroll/frontend/widgets/salary_calculation.dart';

class UserAttendanceList extends StatefulWidget {
  final int userId;
  final bool showSalaryBox;

  const UserAttendanceList({
    Key? key,
    required this.userId,
    this.showSalaryBox = true,
  }) : super(key: key);

  @override
  State<UserAttendanceList> createState() => _UserAttendanceListState();
}

class _UserAttendanceListState extends State<UserAttendanceList> {
  List<dynamic> _attendanceHistory = [];
  int _paidLeaveDays = 0;
  int _absentDays = 0;
  Map<String, dynamic>? _employeeDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final historyFuture = http.get(
        Uri.parse(
          'http://10.0.2.2:3000/api/attendance/history/${widget.userId}',
        ),
      );
      final employeeFuture = http.get(
        Uri.parse('http://10.0.2.2:3000/api/employees/${widget.userId}'),
      );
      final leaveFuture = http.get(
        Uri.parse('http://10.0.2.2:3000/api/leave/employee/${widget.userId}'),
      );

      final results = await Future.wait([
        historyFuture,
        employeeFuture,
        leaveFuture,
      ]);

      if (results[0].statusCode == 200 &&
          results[1].statusCode == 200 &&
          results[2].statusCode == 200) {
        final List<dynamic> history = jsonDecode(results[0].body);
        final List<dynamic> leaves = jsonDecode(results[2].body);

        final DateTime now = DateTime.now();

        final List<dynamic> currentMonthHistory =
            history.where((item) {
              DateTime date = DateTime.parse(item['date']);
              return date.year == now.year && date.month == now.month;
            }).toList();

        int approvedLeaveDays = 0;
        for (var leave in leaves) {
          if (leave['status'] == 'Approved') {
            DateTime start = DateTime.parse(leave['start_date']);
            DateTime end = DateTime.parse(leave['end_date']);

            for (
              DateTime day = start;
              day.isBefore(end.add(const Duration(days: 1)));
              day = day.add(const Duration(days: 1))
            ) {
              if (day.year == now.year && day.month == now.month) {
                approvedLeaveDays++;
              }
            }
          }
        }

        int absent = 30 - currentMonthHistory.length - approvedLeaveDays;
        if (absent < 0) absent = 0;

        setState(() {
          _attendanceHistory = currentMonthHistory;
          _paidLeaveDays = approvedLeaveDays;
          _absentDays = absent;
          _employeeDetails = jsonDecode(results[1].body);
          _isLoading = false;
        });
      } else {
        throw 'Failed to load data';
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: Color(0xFF188984)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SummaryCard(
                  label: "Present",
                  count: _attendanceHistory.length,
                  color: Colors.green,
                ),
                SummaryCard(
                  label: "Absent",
                  count: _absentDays,
                  color: Colors.red,
                ),
                SummaryCard(
                  label: "Leave",
                  count: _paidLeaveDays,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.showSalaryBox &&
                _employeeDetails != null &&
                _employeeDetails!['salary'] != null)
              SalaryCalculationTable(
                totalSalary:
                    double.tryParse(_employeeDetails!['salary'].toString()) ??
                    0,
                attendedDays: _attendanceHistory.length,
                paidLeaveDays: _paidLeaveDays,
                maritalStatus:
                    _employeeDetails!['marital_status'] ?? 'unmarried',
                employmentType: _employeeDetails!['employment_type'],
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
                DateTime fullDate = DateTime.parse(item['date']);
                String formattedDate = DateFormat(
                  'EEE, MMM d',
                ).format(fullDate);
                String inTime = item['punch_in_time'] ?? '--:--';
                String outTime = item['punch_out_time'] ?? '--:--';

                return AttendanceCard(
                  date: formattedDate,
                  status:
                      item['punch_in_distance'] != null ? 'Present' : 'Logged',
                  hours: item['punch_in_location_name'] ?? 'Address not found',
                  checkIn: inTime,
                  checkOut: outTime,
                  onTap: () => showDetailsDialog(context, item),
                );
              }).toList(),
          ],
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
    Key? key,
    required this.label,
    required this.count,
    required this.color,
  }) : super(key: key);

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
    Key? key,
    required this.date,
    required this.status,
    required this.hours,
    required this.checkIn,
    required this.checkOut,
    required this.onTap,
  }) : super(key: key);

  Color getStatusColor() {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Leave':
        return Colors.blue;
      default:
        return const Color(0xFF188984);
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
