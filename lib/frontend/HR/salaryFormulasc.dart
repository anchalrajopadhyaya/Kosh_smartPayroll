import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:payroll/frontend/utils/config.dart';

class SalaryFormulasScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const SalaryFormulasScreen({required this.userData, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF1F6),
      appBar: AppBar(
        title: const Text('Salary Calculation Formulas'),
        backgroundColor: const Color.fromARGB(255, 24, 137, 132),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFormulaCard(
            context,
            'Basic Logic',
            '• Standard Month = 30 Days\n'
                '• Daily Rate = Total Salary / 30\n'
                '• Basic Salary = Total Salary * 60%\n'
                '• Basic Daily Rate = Basic Salary / 30',
          ),
          _buildFormulaCard(
            context,
            'Deductions (Leaves)',
            '• Absent Days = 30 - Attended Days - Paid Leaves\n'
                '• Unpaid Leave Deduction = Daily Rate * Absent Days\n'
                '• Gross Payable = Total Salary - Unpaid Leave Deduction\n'
                '• Basic Payable = Basic Salary - (Basic Daily Rate * Absent Days)',
          ),
          _buildFormulaCard(
            context,
            'Social Security Fund (SSF)',
            '• Employee Contribution = Basic Payable * 11%\n'
                '• Employer Contribution = Basic Payable * 20%\n'
                '• Taxable Income = (Gross Payable * 12) - (SSF Employee * 12)',
          ),
          _buildFormulaCard(
            context,
            'Income Tax Brackets (Unmarried)',
            '• Up to 500,000 : 1%\n'
                '• 500,001 to 700,000 : + 10%\n'
                '• 700,001 to 1,000,000 : + 20%\n'
                '• 1,000,001 to 2,000,000 : + 30%\n'
                '• Above 2,000,000 : + 36%',
          ),
          _buildFormulaCard(
            context,
            'Income Tax Brackets (Married)',
            '• Up to 600,000 : 1%\n'
                '• 600,001 to 800,000 : + 10%\n'
                '• 800,001 to 1,100,000 : + 20%\n'
                '• 1,100,001 to 2,000,000 : + 30%\n'
                '• Above 2,000,000 : + 36%',
          ),
          _buildFormulaCard(
            context,
            'Special Tax Rebates',
            '• Female Rebate: If Unmarried and Female, 10% deduction is applied to the final calculated Tax amount.\n'
                '• Monthly Tax = Final Annual Tax / 12',
          ),
          _buildFormulaCard(
            context,
            'Net Take Home Salary',
            '• Net Take Home = Gross Payable - SSF Employee - Monthly Tax',
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaCard(BuildContext context, String title, String details) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showChangeRequestDialog(context, title),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF188984),
                      ),
                    ),
                  ),
                  const Icon(Icons.edit_note, color: Colors.grey, size: 24),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                details,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangeRequestDialog(BuildContext context, String ruleTitle) {
    final TextEditingController textController = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing during API request
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Request Change for:\n$ruleTitle',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    enabled: !isSending,
                    decoration: InputDecoration(
                      hintText:
                          'Describe the formula changes needed (e.g., Change bracket limit, adjust percentage, etc.)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  if (isSending) ...[
                    const SizedBox(height: 16),
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF188984),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending ? null : () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      isSending
                          ? null
                          : () async {
                            final description = textController.text.trim();
                            if (description.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please describe the changes needed.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            setState(() {
                              isSending = true;
                            });

                            try {
                              final response = await http.post(
                                AppConfig.apiUri(
                                  '/api/payroll/formula-request',
                                ),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  'ruleTitle': ruleTitle,
                                  'description': description,
                                  'hrName': userData['name'] ?? 'HR',
                                  'hrEmail': userData['email'] ?? '',
                                }),
                              );

                              if (response.statusCode == 200) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: const [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Change request sent to developers!',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(
                                      0xFF1FB45C,
                                    ), // Green
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              } else {
                                throw 'Server returned status: ${response.statusCode}';
                              }
                            } catch (e) {
                              setState(() {
                                isSending = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to send request: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF188984),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Send Request'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
