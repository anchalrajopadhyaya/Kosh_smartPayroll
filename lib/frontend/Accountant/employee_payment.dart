import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:payroll/frontend/utils/config.dart';
import 'package:payroll/frontend/widgets/salary_calculation.dart';

class EmployeePaymentScreen extends StatefulWidget {
  const EmployeePaymentScreen({super.key});

  @override
  State<EmployeePaymentScreen> createState() => _EmployeePaymentScreenState();
}

class _EmployeePaymentScreenState extends State<EmployeePaymentScreen> {
  List<dynamic> _employees = [];
  List<dynamic> _filteredEmployees = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(AppConfig.apiUri('/api/employees'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _employees = data['employees'] ?? [];
          _filteredEmployees = _employees;
          _isLoading = false;
        });
      } else {
        throw 'Failed to load employees: ${response.statusCode}';
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterEmployees(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEmployees = _employees;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredEmployees =
            _employees.where((emp) {
              final fullName =
                  "${emp['first_name'] ?? ''} ${emp['last_name'] ?? ''}"
                      .toLowerCase();
              final code =
                  (emp['employee_code'] ?? '').toString().toLowerCase();
              return fullName.contains(lowerQuery) || code.contains(lowerQuery);
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF1F6),
      appBar: AppBar(
        title: const Text(
          'Employee Payroll Handover',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF188984),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search box
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: _filterEmployees,
              decoration: InputDecoration(
                hintText: 'Search by name or code...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF188984)),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterEmployees('');
                          },
                        )
                        : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF188984),
                      ),
                    )
                    : _error != null
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 60,
                            ),
                            const SizedBox(height: 12),
                            Text("Error: $_error", textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchEmployees,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF188984),
                              ),
                              child: const Text(
                                "Retry",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : _filteredEmployees.isEmpty
                    ? const Center(
                      child: Text(
                        "No employees found.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _fetchEmployees,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final emp = _filteredEmployees[index];
                          final name =
                              "${emp['first_name'] ?? ''} ${emp['last_name'] ?? ''}"
                                  .trim();
                          final code = emp['employee_code'] ?? '';
                          final jobTitle = emp['job_title'] ?? 'Staff';
                          final dept = emp['department'] ?? 'General';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: const Color(
                                  0xFF188984,
                                ).withOpacity(0.1),
                                radius: 26,
                                child: Text(
                                  name.isNotEmpty ? name[0] : 'E',
                                  style: const TextStyle(
                                    color: Color(0xFF188984),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "$jobTitle • $dept\nID: $code",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            EmployeePaymentDetailsScreen(
                                              employee: emp,
                                            ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

class EmployeePaymentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> employee;
  const EmployeePaymentDetailsScreen({super.key, required this.employee});

  @override
  State<EmployeePaymentDetailsScreen> createState() =>
      _EmployeePaymentDetailsScreenState();
}

class _EmployeePaymentDetailsScreenState
    extends State<EmployeePaymentDetailsScreen> {
  Map<String, dynamic>? _payrollDetails;
  bool _isLoading = true;
  bool _isProcessingPay = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPayrollData();
  }

  Future<void> _fetchPayrollData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final DateTime now = DateTime.now();
      final empId = widget.employee['id'];
      final url = AppConfig.apiUri(
        '/api/payroll/calculate/$empId?month=${now.month}&year=${now.year}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _payrollDetails = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw 'Failed to load salary calculations: ${response.statusCode}';
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _processPayment(double netSalary) async {
    setState(() {
      _isProcessingPay = true;
    });

    try {
      final DateTime now = DateTime.now();
      final response = await http.post(
        AppConfig.apiUri('/api/payroll/pay'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employeeId': widget.employee['id'],
          'amount': netSalary,
          'month': now.month,
          'year': now.year,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showSuccessDialog(
          data['message'] ?? 'Payment processed successfully.',
        );
      } else {
        throw 'Payment server error: ${response.statusCode}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessingPay = false;
      });
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 36,
                    child: Icon(Icons.check, color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Payment Processed!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back to employee list
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF188984),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Back to Directory',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name =
        "${widget.employee['first_name'] ?? ''} ${widget.employee['last_name'] ?? ''}"
            .trim();
    final code = widget.employee['employee_code'] ?? '';
    final jobTitle = widget.employee['job_title'] ?? 'Staff';
    final dept = widget.employee['department'] ?? 'General';

    return Scaffold(
      backgroundColor: const Color(0xFFEBF1F6),
      appBar: AppBar(
        title: const Text('Payment Breakdown'),
        backgroundColor: const Color(0xFF188984),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF188984)),
              )
              : _error != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 12),
                      Text("Error: $_error", textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchPayrollData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF188984),
                        ),
                        child: const Text(
                          "Retry",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Employee card
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(
                                0xFF188984,
                              ).withOpacity(0.1),
                              radius: 30,
                              child: Text(
                                name.isNotEmpty ? name[0] : 'E',
                                style: const TextStyle(
                                  color: Color(0xFF188984),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "$jobTitle • $dept",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    "Code: $code",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Breakdown table
                    if (_payrollDetails != null) ...[
                      SalaryCalculationTable(
                        totalSalary:
                            double.tryParse(
                              _payrollDetails!['totalSalary'].toString(),
                            ) ??
                            0,
                        unpaidLeaves:
                            int.tryParse(
                              _payrollDetails!['unpaidLeaves'].toString(),
                            ) ??
                            0,
                        unpaidDeduction:
                            double.tryParse(
                              _payrollDetails!['unpaidDeduction'].toString(),
                            ) ??
                            0,
                        ssfEmployee:
                            double.tryParse(
                              _payrollDetails!['ssfEmployee'].toString(),
                            ) ??
                            0,
                        tax:
                            double.tryParse(
                              _payrollDetails!['tax'].toString(),
                            ) ??
                            0,
                        netSalary:
                            double.tryParse(
                              _payrollDetails!['netSalary'].toString(),
                            ) ??
                            0,
                        isIntern: _payrollDetails!['isIntern'] ?? false,
                      ),
                      const SizedBox(height: 24),
                      // Pay button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isProcessingPay
                                  ? null
                                  : () => _processPayment(
                                    double.tryParse(
                                          _payrollDetails!['netSalary']
                                              .toString(),
                                        ) ??
                                        0,
                                  ),
                          icon:
                              _isProcessingPay
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.payment, size: 24),
                          label: Text(
                            _isProcessingPay
                                ? 'Processing...'
                                : 'PAY NPR ${(double.tryParse(_payrollDetails!['netSalary'].toString()) ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF188984),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
