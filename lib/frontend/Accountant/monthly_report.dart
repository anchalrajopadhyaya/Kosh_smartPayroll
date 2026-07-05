import 'package:payroll/frontend/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});
  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  bool _isLoading = true;
  String? _error;
  double _totalPayouts = 0.0;
  double _taxWithheld = 0.0;
  double _ssfEmployer = 0.0;
  int _approvedLeaves = 0;
  int _employeeCount = 0;
  List<dynamic> _employeesList = [];
  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final DateTime now = DateTime.now();
      final response = await http.get(
        Uri.parse(
          '${AppConfig.baseUrl}/api/payroll/monthly-summary?month=${now.month}&year=${now.year}',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _totalPayouts =
              double.tryParse(data['totalPayouts'].toString()) ?? 0.0;
          _taxWithheld = double.tryParse(data['taxWithheld'].toString()) ?? 0.0;
          _ssfEmployer = double.tryParse(data['ssfEmployer'].toString()) ?? 0.0;
          _approvedLeaves =
              int.tryParse(data['approvedLeaves'].toString()) ?? 0;
          _employeeCount = int.tryParse(data['employeeCount'].toString()) ?? 0;
          _employeesList = data['details'] ?? [];
          _isLoading = false;
        });
      } else {
        throw 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF1F6),
      appBar: AppBar(
        title: const Text('HR Monthly Handover'),
        backgroundColor: const Color.fromARGB(255, 24, 137, 132),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSummary,
        child:
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
                          onPressed: _fetchSummary,
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
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatusHeader(),
                      const SizedBox(height: 20),
                      _buildSummaryMetrics(),
                      const SizedBox(height: 24),
                      _buildEmployeeBreakdown(),
                      const SizedBox(height: 24),
                      _buildReportDetails(),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFBA826), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFFBA826), size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Report Status: IN REVIEW",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "Please review the aggregated monthly payroll metrics for $_employeeCount active employees before initiating ledger transfers.",
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Consolidated Overview",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                "Total Payouts",
                "NPR ${_totalPayouts.toStringAsFixed(2)}",
                Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                "Tax Withheld",
                "NPR ${_taxWithheld.toStringAsFixed(2)}",
                Colors.redAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                "SSF (Company)",
                "NPR ${_ssfEmployer.toStringAsFixed(2)}",
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                "Approved Leaves",
                "$_approvedLeaves Days",
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Employee Breakdown",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _employeesList.isEmpty
              ? const Text(
                "No employee payroll records found.",
                style: TextStyle(color: Colors.grey),
              )
              : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _employeesList.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final emp = _employeesList[index];
                  final double net =
                      double.tryParse(emp['netSalary'].toString()) ?? 0.0;
                  final double tax =
                      double.tryParse(emp['tax'].toString()) ?? 0.0;
                  final double ssf =
                      double.tryParse(emp['ssfEmployee'].toString()) ?? 0.0;
                  final String name = emp['name'] ?? 'Unknown';
                  final String code = emp['employeeCode'] ?? '';
                  final String type = emp['employmentType'] ?? 'Full-Time';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "$code • $type",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Net: NPR ${net.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Tax: NPR ${tax.toStringAsFixed(2)} | SSF: NPR ${ssf.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  Widget _buildReportDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "HR Sign-off Attachments",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const pwIconPlaceholder(color: Colors.red),
            title: const Text("March_2026_Final_Payroll.csv"),
            subtitle: const Text("Uploaded by HR Admin (12 hrs ago)"),
            trailing: IconButton(
              icon: const Icon(Icons.download, color: Color(0xFF188984)),
              onPressed: () {},
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const pwIconPlaceholder(color: Colors.blue),
            title: const Text("SSF_Declaration.pdf"),
            subtitle: const Text("Auto-generated sheet"),
            trailing: IconButton(
              icon: const Icon(Icons.download, color: Color(0xFF188984)),
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.verified),
              label: const Text(
                'Acknowledge & Finalize',
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Monthly payroll finalized and locked successfully!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class pwIconPlaceholder extends StatelessWidget {
  final Color color;
  const pwIconPlaceholder({super.key, required this.color});
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.insert_drive_file, color: color, size: 36);
  }
}
