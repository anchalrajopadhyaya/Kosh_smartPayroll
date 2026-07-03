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
  Map<String, dynamic>? _payrollDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final userId = widget.userData['id'];
      final DateTime now = DateTime.now();

      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:3000/api/payroll/calculate/$userId?month=${now.month}&year=${now.year}',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _payrollDetails = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw 'Failed to load payroll data';
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

    if (_payrollDetails == null || _payrollDetails!['totalSalary'] == null) {
      return const Center(
        child: Text(
          "Salary details not yet configured.\nPlease contact HR.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final double totalSalary =
        double.tryParse(_payrollDetails!['totalSalary'].toString()) ?? 0;
    final int unpaidLeaves =
        int.tryParse(_payrollDetails!['unpaidLeaves'].toString()) ?? 0;
    final double unpaidDeduction =
        double.tryParse(_payrollDetails!['unpaidDeduction'].toString()) ?? 0;
    final double ssfEmployee =
        double.tryParse(_payrollDetails!['ssfEmployee'].toString()) ?? 0;
    final double tax = double.tryParse(_payrollDetails!['tax'].toString()) ?? 0;
    final double netSalary =
        double.tryParse(_payrollDetails!['netSalary'].toString()) ?? 0;
    final bool isIntern = _payrollDetails!['isIntern'] ?? false;

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
              unpaidLeaves: unpaidLeaves,
              unpaidDeduction: unpaidDeduction,
              ssfEmployee: ssfEmployee,
              tax: tax,
              netSalary: netSalary,
              isIntern: isIntern,
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
                    payrollDetails: _payrollDetails!,
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
