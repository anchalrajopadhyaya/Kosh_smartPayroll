import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateAndPrintPayslip({
  required Map<String, dynamic> payrollDetails,
  required String companyName,
}) async {
  final double totalSalary =
      double.tryParse(payrollDetails['totalSalary'].toString()) ?? 0;
  final int unpaidLeaves =
      int.tryParse(payrollDetails['unpaidLeaves'].toString()) ?? 0;
  final double unpaidDeduction =
      double.tryParse(payrollDetails['unpaidDeduction'].toString()) ?? 0;
  final double ssfEmployee =
      double.tryParse(payrollDetails['ssfEmployee'].toString()) ?? 0;
  final double tax = double.tryParse(payrollDetails['tax'].toString()) ?? 0;
  final double netSalary =
      double.tryParse(payrollDetails['netSalary'].toString()) ?? 0;
  final bool isIntern = payrollDetails['isIntern'] ?? false;
  final double rebate =
      double.tryParse(payrollDetails['rebate'].toString()) ?? 0;

  final String name = payrollDetails['name'] ?? 'N/A';
  final String employeeCode = payrollDetails['employeeCode'] ?? 'N/A';
  final String jobTitle = payrollDetails['jobTitle'] ?? 'N/A';
  final String department = payrollDetails['department'] ?? 'N/A';

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
                          'Name: $name',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Employee Code: $employeeCode'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Job Title: $jobTitle'),
                        pw.SizedBox(height: 4),
                        pw.Text('Department: $department'),
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
                    'Unpaid Leave Deductions (-$unpaidLeaves Days)',
                    '-${unpaidDeduction.toStringAsFixed(2)}',
                  ],
                  if (!isIntern)
                    [
                      'SSF Deduction (11%)',
                      '-${ssfEmployee.toStringAsFixed(2)}',
                    ],
                  if (rebate > 0)
                    [
                      'Female Tax Rebate (10%)',
                      '-${rebate.toStringAsFixed(2)}',
                    ],
                  [
                    isIntern
                        ? 'Intern Income Tax (1%)'
                        : 'Income Tax (Monthly)',
                    '-${tax.toStringAsFixed(2)}',
                  ],
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
                      'NPR ${netSalary.toStringAsFixed(2)}',
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
    name: 'Payslip_${name.replaceAll(' ', '_')}_${DateTime.now().year}',
  );
}
