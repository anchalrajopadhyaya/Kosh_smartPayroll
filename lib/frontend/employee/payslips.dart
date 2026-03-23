import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:payroll/frontend/widgets/salary_calculation.dart';
import 'dart:convert';

class PayslipScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const PayslipScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<PayslipScreen> createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  int _attendedDays = 0;
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

      final results = await Future.wait([historyFuture, employeeFuture]);

      if (results[0].statusCode == 200 && results[1].statusCode == 200) {
        final List<dynamic> history = jsonDecode(results[0].body);
        setState(() {
          _attendedDays = history.length;
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

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "My Payslip",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF141927),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Estimated payout based on current attendance",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          SalaryCalculationTable(
            totalSalary: totalSalary,
            attendedDays: _attendedDays,
            maritalStatus: maritalStatus,
          ),
        ],
      ),
    );
  }
}
