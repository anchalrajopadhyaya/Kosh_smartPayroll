import 'package:flutter/material.dart';
import 'package:payroll/frontend/notification.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class EmployeeDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EmployeeDashboard({super.key, required this.userData});
  @override
  State<EmployeeDashboard> createState() => EmployeeDashboardState();
}

class EmployeeDashboardState extends State<EmployeeDashboard> {
  bool _isLoading = false;
  Future<void> _handlePunchIn() async {
    setState(() => _isLoading = true);
    try {
      // 1. Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }
      // 2. Get Location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      // 3. Prepare Data
      final String locationString =
          "${position.latitude}, ${position.longitude}";
      final DateTime now = DateTime.now();
      final String date = DateFormat('yyyy-MM-dd').format(now);
      final String time = DateFormat('HH:mm').format(now);
      // 4. Send to Backend
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/attendance/punch-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employeeId': widget.userData['id'],
          'location': locationString,
          'date': date,
          'time': time,
        }),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Punch In Successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw 'Failed: ${response.body}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f9),
      appBar: AppBar(
        title: Text("Hello, ${widget.userData['firstName']}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const notification()),
                ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Salary Card (Kept as is)
            _buildSalaryCard(),

            const SizedBox(height: 24),

            // PUNCH IN BUTTON
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handlePunchIn,
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.fingerprint, size: 28),
                label: Text(
                  _isLoading ? "Processing..." : "PUNCH IN",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF188984),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Leaves Section (Kept as is)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Leaves",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _leaveBox("Annual Leave", "12 Days")),
                const SizedBox(width: 12),
                Expanded(child: _leaveBox("Sick Leave", "5 Days")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ... (Helper methods: _buildSalaryCard, _leaveBox, etc. would be roughly same as before or refactored)
  Widget _buildSalaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF188984), Color(0xFF0F6E6E)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("CURRENT SALARY", style: TextStyle(color: Colors.white70)),
          Text(
            "NPR ${widget.userData['salary']}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _leaveBox(String title, String days) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(
            days,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF188984),
            ),
          ),
        ],
      ),
    );
  }
}
