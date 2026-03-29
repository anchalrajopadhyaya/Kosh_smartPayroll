import 'package:flutter/material.dart';
import 'package:payroll/frontend/attendance.dart';
import 'package:payroll/frontend/employee/dashboard.dart';
import 'package:payroll/frontend/employee/navemp.dart';
import 'package:payroll/frontend/employee/payslips.dart';
import 'package:payroll/frontend/employee/profile.dart';
import 'package:payroll/frontend/HR/hr_attendance.dart';
import 'package:payroll/frontend/HR/hr_dashboard.dart';
import 'package:payroll/frontend/HR/empDetails.dart';
import 'package:payroll/frontend/HR/navhr.dart';

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
      EmployeeDashboard(userData: widget.userData),
      PayslipScreen(userData: widget.userData),
      AttendanceContent(userData: widget.userData),
      ProfileScreen(userData: widget.userData),
    ];
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index; //updates index and shows the selected screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Nav(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}

class HrHomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HrHomeScreen({super.key, required this.userData});

  @override
  State<HrHomeScreen> createState() => _HrHomeScreenState();
}

class _HrHomeScreenState extends State<HrHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HrDashboardScreen(
        userName: widget.userData['name'] ?? 'User',
        onEmployeesTap: () => _onTabSelected(1),
      ),
      const EmployeeScreen(),
      const HrAttendanceScreen(),
      const Center(child: Text("Settings Screen")),
    ];
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'HR Dashboard';
      case 1:
        return 'Employee Management';
      case 2:
        return 'Attendance History';
      case 3:
        return 'Settings';
      default:
        return 'Kosh Payroll';
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _currentIndex == 0
              ? null
              : AppBar(
                title: Text(_getAppBarTitle()),
                backgroundColor: const Color.fromARGB(255, 24, 137, 132),
                foregroundColor: Colors.white,
                centerTitle: true,
                elevation: 0,
              ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: HrNav(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
