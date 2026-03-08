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
  List<dynamic> _allAttendance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllAttendance();
  }

  Future<void> _fetchAllAttendance() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/attendance/all'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _allAttendance = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw 'Failed to load attendance';
      }
    } catch (e) {
      print('Error fetching all attendance: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f9),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF188984)),
              )
              : RefreshIndicator(
                onRefresh: _fetchAllAttendance,
                child:
                    _allAttendance.isEmpty
                        ? const Center(
                          child: Text("No attendance records found."),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _allAttendance.length,
                          itemBuilder: (context, index) {
                            final item = _allAttendance[index];
                            final employee = item['employee'] ?? {};
                            final firstName =
                                employee['first_name'] ?? 'Unknown';
                            final lastName = employee['last_name'] ?? '';
                            final fullName = "$firstName $lastName".trim();

                            DateTime fullDate = DateTime.parse(item['date']);
                            String formattedDate = DateFormat(
                              'EEE, MMM d',
                            ).format(fullDate);

                            String inTime = item['punch_in_time'] ?? '--:--';
                            String outTime = item['punch_out_time'] ?? '--:--';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    top: 8,
                                  ),
                                  child: Text(
                                    fullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF188984),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                AttendanceCard(
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
                                ),
                                const SizedBox(height: 8),
                              ],
                            );
                          },
                        ),
              ),
    );
  }
}
