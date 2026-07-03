import 'package:flutter/material.dart';

class SalaryCalculationTable extends StatelessWidget {
  final double totalSalary;
  final int unpaidLeaves;
  final double unpaidDeduction;
  final double ssfEmployee;
  final double tax;
  final double netSalary;
  final bool isIntern;

  const SalaryCalculationTable({
    super.key,
    required this.totalSalary,
    required this.unpaidLeaves,
    required this.unpaidDeduction,
    required this.ssfEmployee,
    required this.tax,
    required this.netSalary,
    required this.isIntern,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Monthly Salary Computation",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 48,
                columnSpacing: 20,
                columns: const [
                  DataColumn(
                    label: Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Amount (NPR)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: [
                  _buildDataRow(
                    'Base Gross Salary',
                    totalSalary.toStringAsFixed(2),
                  ),
                  _buildDataRow(
                    'Unpaid Leave (-$unpaidLeaves Days)',
                    '-${unpaidDeduction.toStringAsFixed(2)}',
                    isDeduction: true,
                  ),
                  if (!isIntern)
                    _buildDataRow(
                      'SSF Deduction (11%)',
                      '-${ssfEmployee.toStringAsFixed(2)}',
                      isDeduction: true,
                    ),
                  _buildDataRow(
                    isIntern
                        ? 'Intern Income Tax (1%)'
                        : 'Income Tax (FY 80/81)',
                    '-${tax.toStringAsFixed(2)}',
                    isDeduction: true,
                  ),
                  _buildDataRow(
                    'Final Take Home Pay',
                    netSalary.toStringAsFixed(2),
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(
    String title,
    String amount, {
    bool isDeduction = false,
    bool isTotal = false,
  }) {
    return DataRow(
      color:
          isTotal
              ? WidgetStateProperty.all(
                const Color(0xFF188984).withOpacity(0.1),
              )
              : null,
      cells: [
        DataCell(
          Text(
            title,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        DataCell(
          Text(
            amount,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w800,
              color:
                  isDeduction
                      ? Colors.red
                      : (isTotal ? const Color(0xFF188984) : Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}
