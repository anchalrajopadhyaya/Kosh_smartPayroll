import 'package:flutter/material.dart';
import 'package:payroll/frontend/employee/payslips.dart';
import 'package:payroll/frontend/attendance.dart';
import 'package:payroll/frontend/employee/profile.dart';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:payroll/frontend/notification.dart';
import 'package:payroll/frontend/widgets/Accountant/monthly_report.dart';
import 'package:payroll/frontend/widgets/Accountant/nav_accountant.dart';
import 'package:payroll/frontend/widgets/daily_punchesDialog.dart';
import 'package:payroll/frontend/employee/applyLeave.dart';
import 'package:payroll/frontend/employee/emp_feedback.dart';

class AccountantDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AccountantDashboardScreen({super.key, required this.userData});

  @override
  State<AccountantDashboardScreen> createState() =>
      _AccountantDashboardScreenState();
}

class _AccountantDashboardScreenState extends State<AccountantDashboardScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _AccountantHomeContent(userData: widget.userData),
      PayslipScreen(userData: widget.userData),
      AttendanceContent(userData: widget.userData),
      const MonthlyReportScreen(),
      ProfileScreen(userData: widget.userData),
    ];
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AccountantNav(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}

class _AccountantHomeContent extends StatefulWidget {
  final Map<String, dynamic> userData;
  const _AccountantHomeContent({required this.userData});

  @override
  State<_AccountantHomeContent> createState() => _AccountantHomeContentState();
}

class _AccountantHomeContentState extends State<_AccountantHomeContent> {
  bool _isLoading = false;
  String _status = 'PUNCHED_OUT';
  int _employeeCount = 0;
  bool _isLoadingCount = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceStatus();
    _fetchEmployeeCount();
  }

  Future<void> _fetchEmployeeCount() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/employees'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> employees = data['employees'] ?? [];
        if (mounted) {
          setState(() {
            _employeeCount = employees.length;
            _isLoadingCount = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCount = false);
      }
    }
  }

  Future<void> _fetchAttendanceStatus() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:3000/api/attendance/status/${widget.userData['id']}',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _status = data['status'];
        });
      }
    } catch (e) {
      print('Error fetching status: $e');
    }
  }

  Future<void> _handlePunchAction() async {
    if (_status == 'PUNCHED_IN') {
      await _handlePunchOut();
    } else {
      await _handlePunchIn();
    }
  }

  Future<void> _handlePunchIn() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final String locationString =
          "${position.latitude}, ${position.longitude}";
      final DateTime now = DateTime.now();
      final String date = DateFormat('yyyy-MM-dd').format(now);
      final String time = DateFormat('HH:mm').format(now);

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
        setState(() => _status = 'PUNCHED_IN');
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

  Future<void> _handlePunchOut() async {
    setState(() => _isLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final String locationString =
          "${position.latitude}, ${position.longitude}";
      final DateTime now = DateTime.now();
      final String date = DateFormat('yyyy-MM-dd').format(now);
      final String time = DateFormat('HH:mm').format(now);

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/attendance/punch-out'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employeeId': widget.userData['id'],
          'location': locationString,
          'date': date,
          'time': time,
        }),
      );
      if (response.statusCode == 200) {
        setState(() => _status = 'PUNCHED_OUT');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Punch Out Successful!'),
            backgroundColor: Colors.orange,
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
      backgroundColor: const Color(0xFFEBF1F6),
      appBar: AppBar(
        title: Text("Accountant: ${widget.userData['firstName']}"),
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
            _buildSalaryCard(),
            const SizedBox(height: 24),
            _buildAccountantStats(),
            const SizedBox(height: 24),

            // DYNAMIC PUNCH BUTTON
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handlePunchAction,
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
                        : Icon(
                          _status == 'PUNCHED_IN'
                              ? Icons.logout
                              : Icons.fingerprint,
                          size: 28,
                        ),
                label: Text(
                  _isLoading
                      ? "Processing..."
                      : (_status == 'PUNCHED_IN' ? "PUNCH OUT" : "PUNCH IN"),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _status == 'PUNCHED_IN'
                          ? Colors.orange.shade700
                          : const Color(0xFF188984),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) =>
                            DailyPunchesDialog(userData: widget.userData),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text(
                  'VIEW DAILY PUNCHES',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF188984),
                  side: const BorderSide(color: Color(0xFF188984), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ApplyLeaveScreen(userData: widget.userData),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text(
                  'APPLY FOR LEAVE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF188984),
                  side: const BorderSide(color: Color(0xFF188984), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmployeeFeedbackScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.feedback_outlined),
                label: const Text(
                  'ANONYMOUS FEEDBACK',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFBA826),
                  side: const BorderSide(color: Color(0xFFFBA826), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildAccountantStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFBA826),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.people_alt_outlined,
              size: 100,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Active Employees',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLoadingCount ? '...' : _employeeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
