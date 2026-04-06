import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:payroll/frontend/widgets/salary_calculation.dart';
import 'package:payroll/frontend/employee/payslip_generator.dart';

import 'dart:convert';

class PayslipScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const PayslipScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<PayslipScreen> createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  int _attendedDays = 0;
  int _paidLeaveDays = 0;
  Map<String, dynamic>? _employeeDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final userId = widget.userData['id'];

      final historyFuture = http.get(
        Uri.parse('http://10.0.2.2:3000/api/attendance/history/$userId'),
      );
      final employeeFuture = http.get(
        Uri.parse('http://10.0.2.2:3000/api/employees/$userId'),
      );
      final leaveFuture = http.get(
        Uri.parse('http://10.0.2.2:3000/api/leave/employee/$userId'),
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

        setState(() {
          _attendedDays = currentMonthHistory.length;
          _paidLeaveDays = approvedLeaveDays;
          _employeeDetails = jsonDecode(results[1].body);
          _isLoading = false;
        });
      } else {
        throw 'Failed to load data';
      }
    } catch (e) {
      print('Error fetching payslip data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF188984)),
      );
    }

    if (_employeeDetails == null || _employeeDetails!['salary'] == null) {
      return const Center(
        child: Text(
          "Salary details not yet configured.\nPlease contact HR.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final totalSalary =
        double.tryParse(_employeeDetails!['salary'].toString()) ?? 0;
    final maritalStatus = _employeeDetails!['marital_status'] ?? 'unmarried';

    return Scaffold(
      backgroundColor: const Color(0xfff4f6f9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF188984),
        title: const Text(
          "My Payslip",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              "Estimated payout based on current attendance",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            SalaryCalculationTable(
              totalSalary: totalSalary,
              attendedDays: _attendedDays,
              paidLeaveDays: _paidLeaveDays,
              maritalStatus: maritalStatus,
              employmentType: _employeeDetails!['employment_type'],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text(
                  'Download Official Payslip',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF188984),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  generateAndPrintPayslip(
                    employeeDetails: _employeeDetails!,
                    attendedDays: _attendedDays,
                    paidLeaveDays: _paidLeaveDays,
                    companyName: 'Kosh Smart Payroll Ltd.',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
