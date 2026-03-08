import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showDetailsDialog(BuildContext context, Map<String, dynamic> item) {
  showDialog(
    context: context,
    builder: (context) {
      final dateStr = item['date'] ?? DateTime.now().toIso8601String();
      final date = DateFormat(
        'EEEE, MMMM d, yyyy',
      ).format(DateTime.parse(dateStr));

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        title: Column(
          children: [
            Text(
              date,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: (item['punch_in_distance'] != null
                        ? Colors.green
                        : Colors.blue)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item['punch_in_distance'] != null ? 'Present' : 'Logged',
                style: TextStyle(
                  color:
                      item['punch_in_distance'] != null
                          ? Colors.green
                          : Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailSection(
                title: "PUNCH IN",
                time: item['punch_in_time'] ?? '--:--',
                location: item['punch_in_location_name'] ?? 'Not recorded',
                distance: item['punch_in_distance']?.toString() ?? 'N/A',
                icon: Icons.login,
                color: Colors.green,
              ),
              const Divider(height: 32),
              _buildDetailSection(
                title: "PUNCH OUT",
                time: item['punch_out_time'] ?? '--:--',
                location: item['punch_out_location_name'] ?? 'Not recorded',
                distance: item['punch_out_distance']?.toString() ?? 'N/A',
                icon: Icons.logout,
                color: Colors.orange,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(
                color: Color(0xFF188984),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildDetailSection({
  required String title,
  required String time,
  required String location,
  required String distance,
  required IconData icon,
  required Color color,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _detailRow(Icons.access_time, "Time", time),
      const SizedBox(height: 8),
      _detailRow(Icons.location_on_outlined, "Location", location),
      const SizedBox(height: 8),
      _detailRow(Icons.straighten, "Distance", "$distance km from center"),
    ],
  );
}

Widget _detailRow(IconData icon, String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ],
        ),
      ),
    ],
  );
}
