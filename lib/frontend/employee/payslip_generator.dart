import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateAndPrintPayslip({
  required Map<String, dynamic> employeeDetails,
  required int attendedDays,
  required String companyName,
}) async {
  final totalSalary =
      double.tryParse(employeeDetails['salary'].toString()) ?? 0;
  final maritalStatus = employeeDetails['marital_status'] ?? 'unmarried';
  final gender = employeeDetails['gender'] ?? 'male';

  // Basic calculation logic
  const int standardMonthDays = 30;
  int absentDays = standardMonthDays - attendedDays;
  if (absentDays < 0) absentDays = 0;

  double dailyRate = totalSalary / standardMonthDays;
  double basicSalary = totalSalary * 0.6;
  double basicDailyRate = basicSalary / standardMonthDays;
  double unpaidLeaveDeduction = dailyRate * absentDays;
  double grossPayable = totalSalary - unpaidLeaveDeduction;
  double basicPayable = basicSalary - (basicDailyRate * absentDays);
  double ssfEmployee = basicPayable * 0.11;

  // Tax Calculation Logic
  double annualGross = grossPayable * 12;
  double annualSsf = ssfEmployee * 12;
  double taxableIncome = annualGross - annualSsf;

  double annualTax = 0;
  if (maritalStatus.toLowerCase() == 'unmarried') {
    if (taxableIncome <= 500000) {
      annualTax = taxableIncome * 0.01;
    } else if (taxableIncome <= 700000) {
      annualTax = (500000 * 0.01) + ((taxableIncome - 500000) * 0.10);
    } else if (taxableIncome <= 1000000) {
      annualTax =
          (500000 * 0.01) + (200000 * 0.10) + ((taxableIncome - 700000) * 0.20);
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
          (600000 * 0.01) + (200000 * 0.10) + ((taxableIncome - 800000) * 0.20);
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

  double rebateAmount = 0;
  if (maritalStatus.toLowerCase() == 'unmarried' &&
      gender.toLowerCase() == 'female') {
    rebateAmount = annualTax * 0.10;
    annualTax -= rebateAmount;
  }

  double monthlyTax = annualTax / 12;
  double netTakeHome = grossPayable - ssfEmployee - monthlyTax;

  final doc = pw.Document();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        companyName,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.teal800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Official Monthly Payslip',
                        style: const pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Date: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // EMPLOYEE INFO
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Name: ${employeeDetails['first_name']} ${employeeDetails['last_name']}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Employee Code: ${employeeDetails['employee_code'] ?? 'N/A'}',
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Job Title: ${employeeDetails['job_title'] ?? 'N/A'}',
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Department: ${employeeDetails['department'] ?? 'N/A'}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // TABLE
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 0.5,
                ),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.teal800,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                },
                data: <List<String>>[
                  ['Description', 'Amount (NPR)'],
                  ['Base Gross Salary', totalSalary.toStringAsFixed(2)],
                  [
                    'Unpaid Leave Deductions (-$absentDays Days)',
                    '-${unpaidLeaveDeduction.toStringAsFixed(2)}',
                  ],
                  ['SSF Deduction (11%)', '-${ssfEmployee.toStringAsFixed(2)}'],
                  if (rebateAmount > 0)
                    [
                      'Female Tax Rebate (10%)',
                      '-${(rebateAmount / 12).toStringAsFixed(2)}',
                    ],
                  ['Income Tax (Monthly)', '-${monthlyTax.toStringAsFixed(2)}'],
                ],
              ),
              pw.SizedBox(height: 20),

              // TOTAL ROW
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.teal50,
                  border: pw.Border.symmetric(
                    horizontal: pw.BorderSide(
                      color: PdfColors.teal800,
                      width: 2,
                    ),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'NET TAKE HOME SALARY:',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'NPR ${netTakeHome.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal800,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'This is a computer generated document and requires no signature.',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Powered by Kosh Payroll',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  // Triggers the native standard flutter Print / Save to PDF dialog overlay
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => doc.save(),
    name: 'Payslip_${employeeDetails['first_name']}_${DateTime.now().year}',
  );
}
