import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:payroll/frontend/widgets/attendance_details.dart';
import 'package:payroll/frontend/attendance.dart';

class HrAttendanceScreen extends StatefulWidget {
  const HrAttendanceScreen({super.key});

  @override
  State<HrAttendanceScreen> createState() => _HrAttendanceScreenState();
}

class _HrAttendanceScreenState extends State<HrAttendanceScreen> {
  List<dynamic> _dailyReport = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchDailyReport();
  }

  Future<void> _fetchDailyReport() async {
    setState(() => _isLoading = true);
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:3000/api/attendance/daily?date=$formattedDate',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _dailyReport = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw 'Failed to load report';
      }
    } catch (e) {
      print('Error fetching daily report: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF188984),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchDailyReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f9),
      body: Column(
        children: [
          _buildDateHeader(context),
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF188984),
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _fetchDailyReport,
                      child:
                          _dailyReport.isEmpty
                              ? const Center(child: Text("No employees found."))
                              : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _dailyReport.length,
                                itemBuilder: (context, index) {
                                  final item = _dailyReport[index];
                                  return _buildAttendanceRow(item);
                                },
                              ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    String formattedDate = DateFormat('MMMM dd, yyyy').format(_selectedDate);
    bool isToday =
        DateFormat('yyyy-MM-dd').format(_selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                isToday ? "Today, $formattedDate" : formattedDate,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.edit_calendar, size: 18),
            label: const Text("Change"),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF188984),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(Map<String, dynamic> item) {
    final String fullName = "${item['first_name']} ${item['last_name']}".trim();
    final String status = item['status'];
    final bool isAbsent = status == 'Absent';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap:
            isAbsent ? null : () => showDetailsDialog(context, item['logData']),
        leading: CircleAvatar(
          backgroundColor:
              isAbsent
                  ? Colors.red.shade50
                  : const Color(0xFF188984).withOpacity(0.1),
          child: Text(
            item['first_name'][0],
            style: TextStyle(
              color: isAbsent ? Colors.red : const Color(0xFF188984),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          fullName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['job_title'] ?? item['department'] ?? 'Employee',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (!isAbsent)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.login, size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      item['punch_in_time'] ?? '--:--',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.logout, size: 12, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      item['punch_out_time'] ?? '--:--',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getStatusColor(status).withOpacity(0.5)),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: _getStatusColor(status),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Logged In':
        return Colors.blue;
      case 'Absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
