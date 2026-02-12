import 'package:flutter/material.dart';
import 'package:payroll/frontend/attendance.dart';
import 'package:payroll/frontend/employee/dashboard.dart';
import 'package:payroll/frontend/employee/navemp.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      EmployeeDashboard(userData: widget.userData), // Dashboard -> index 0
      const Center(child: Text("Payslips Screen")), // Payslips -> index 1
      const AttendanceContent(), // Attendance -> index 2
      const Center(child: Text("Profile Screen")), // Profile -> index 3
    ];
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index; // updates index and shows the selected screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _screens[_currentIndex], // <-- Attendance shows when _currentIndex = 2
      bottomNavigationBar: Nav(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
