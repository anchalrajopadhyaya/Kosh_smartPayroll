import 'package:flutter/material.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 20),
            _buildSummaryMetrics(),
            const SizedBox(height: 24),
            _buildReportDetails(),
          ],
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
              children: const [
                Text(
                  "Report Status: IN REVIEW",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  "Please review the aggregated monthly payroll metrics submitted by HR before initiating ledger transfers.",
                  style: TextStyle(color: Colors.black87, fontSize: 13),
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
              child: _metricCard("Total Payouts", "NPR 4,502,000", Colors.teal),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                "Tax Withheld",
                "NPR 320,450",
                Colors.redAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard("SSF (Company)", "NPR 450,200", Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard("Approved Leaves", "42 Days", Colors.blue),
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
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
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
            leading: const Icon(
              Icons.picture_as_pdf,
              color: Colors.red,
              size: 36,
            ),
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
            leading: const Icon(
              Icons.insert_drive_file,
              color: Colors.blue,
              size: 36,
            ),
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
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
