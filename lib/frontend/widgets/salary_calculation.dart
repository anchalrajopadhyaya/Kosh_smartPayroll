import 'package:flutter/material.dart';

class SalaryCalculationTable extends StatelessWidget {
  final double totalSalary;
  final int attendedDays;
  final int paidLeaveDays;
  final String maritalStatus;
  final String? employmentType;

  const SalaryCalculationTable({
    super.key,
    required this.totalSalary,
    required this.attendedDays,
    this.paidLeaveDays = 0,
    this.maritalStatus = 'unmarried',
    this.employmentType,
  });

  @override
  Widget build(BuildContext context) {
    // Basic calculation logic
    const int standardMonthDays = 30;

    int absentDays = standardMonthDays - attendedDays - paidLeaveDays;
    if (absentDays < 0) absentDays = 0;
    int unpaidLeaveDays = absentDays;

    double dailyRate = totalSalary / standardMonthDays;
    double basicSalary = totalSalary * 0.6;
    double basicDailyRate = basicSalary / standardMonthDays;

    double unpaidLeaveDeduction = dailyRate * unpaidLeaveDays;
    double grossPayable = totalSalary - unpaidLeaveDeduction;
    double basicPayable = basicSalary - (basicDailyRate * unpaidLeaveDays);

    bool isIntern = employmentType?.toLowerCase() == 'intern';

    double ssfEmployee = isIntern ? 0.0 : basicPayable * 0.11;

    // Tax Calculation Logic
    double annualGross = grossPayable * 12;
    double annualSsf = ssfEmployee * 12;
    double taxableIncome = annualGross - annualSsf;

    double annualTax = 0;
    if (isIntern) {
      annualTax = taxableIncome * 0.01;
    } else {
      if (maritalStatus.toLowerCase() == 'unmarried') {
        if (taxableIncome <= 500000) {
          annualTax = taxableIncome * 0.01;
        } else if (taxableIncome <= 700000) {
          annualTax = (500000 * 0.01) + ((taxableIncome - 500000) * 0.10);
        } else if (taxableIncome <= 1000000) {
          annualTax =
              (500000 * 0.01) +
              (200000 * 0.10) +
              ((taxableIncome - 700000) * 0.20);
        } else if (taxableIncome <= 2000000) {
          annualTax =
              (500000 * 0.01) +
              (200000 * 0.10) +
              (300000 * 0.20) +
              ((taxableIncome - 1000000) * 0.30);
        } else {
          annualTax =
              (500000 * 0.01) +
              (200000 * 0.10) +
              (300000 * 0.20) +
              (1000000 * 0.30) +
              ((taxableIncome - 2000000) * 0.36);
        }
      } else {
        if (taxableIncome <= 600000) {
          annualTax = taxableIncome * 0.01;
        } else if (taxableIncome <= 800000) {
          annualTax = (600000 * 0.01) + ((taxableIncome - 600000) * 0.10);
        } else if (taxableIncome <= 1100000) {
          annualTax =
              (600000 * 0.01) +
              (200000 * 0.10) +
              ((taxableIncome - 800000) * 0.20);
        } else if (taxableIncome <= 2000000) {
          annualTax =
              (600000 * 0.01) +
              (200000 * 0.10) +
              (300000 * 0.20) +
              ((taxableIncome - 1100000) * 0.30);
        } else {
          annualTax =
              (600000 * 0.01) +
              (200000 * 0.10) +
              (300000 * 0.20) +
              (900000 * 0.30) +
              ((taxableIncome - 2000000) * 0.36);
        }
      }
    }

    double monthlyTax = annualTax / 12;
    double netTakeHome = grossPayable - ssfEmployee - monthlyTax;

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
                    'Unpaid Leave (-$unpaidLeaveDays Days)',
                    '-${unpaidLeaveDeduction.toStringAsFixed(2)}',
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
                    '-${monthlyTax.toStringAsFixed(2)}',
                    isDeduction: true,
                  ),
                  _buildDataRow(
                    'Final Take Home Pay',
                    netTakeHome.toStringAsFixed(2),
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
