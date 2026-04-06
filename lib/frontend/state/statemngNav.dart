import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:payroll/frontend/HR/empDetails.dart';
import 'package:payroll/frontend/HR/hrSettings.dart';
import 'package:payroll/frontend/HR/hr_dashboard.dart';
import 'package:payroll/frontend/HR/navhr.dart';
import 'package:payroll/frontend/attendance.dart';
import 'package:payroll/frontend/employee/dashboard.dart';
import 'package:payroll/frontend/employee/payslips.dart';
import 'package:payroll/frontend/employee/navemp.dart';
import 'package:payroll/frontend/employee/profile.dart';
import 'package:payroll/frontend/hr/hr_attendance.dart';
import 'package:payroll/frontend/widgets/Accountant/monthly_report.dart';
import 'package:payroll/frontend/widgets/Accountant/nav_accountant.dart';

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
  // ── HR mode ──────────────────────────────────────
  int _hrIndex = 0;
  late final List<Widget> _hrScreens;

  // ── Employee personal view ────────────────────────
  bool _isEmployeeView = false;
  bool _isFetching = false;
  Map<String, dynamic>? _employeeData; // cached after first fetch
  int _empIndex = 0;
  List<Widget>? _empScreens;

  @override
  void initState() {
    super.initState();
    _hrScreens = [
      HrDashboardScreen(
        userName: widget.userData['name'] ?? 'User',
        onEmployeesTap: () => setState(() => _hrIndex = 1),
        onPersonalViewTap: _switchToEmployeeView,
      ),
      const EmployeeScreen(),
      const HrAttendanceScreen(),
      HrSettingsScreen(userData: widget.userData),
    ];
  }

  // ── Fetch employee record once, then switch view ──
  Future<void> _switchToEmployeeView() async {
    // Already fetched → just flip the view
    if (_employeeData != null) {
      setState(() {
        _isEmployeeView = true;
        _empIndex = 0;
      });
      return;
    }

    final email = widget.userData['email'] ?? '';
    if (email.isEmpty) return;

    setState(() => _isFetching = true);

    try {
      final res = await http.get(
        Uri.parse(
          'http://10.0.2.2:3000/api/employees/by-email/${Uri.encodeComponent(email)}',
        ),
      );
      if (!mounted) return;

      if (res.statusCode == 200) {
        final emp = jsonDecode(res.body) as Map<String, dynamic>;
        final data = {
          'id': emp['id'],
          'firstName': emp['first_name'],
          'lastName': emp['last_name'],
          'email': emp['email'],
          'salary': emp['salary'],
          'department': emp['department'],
          'jobTitle': emp['job_title'],
          'employeeCode': emp['employee_code'],
          'maritalStatus': emp['marital_status'],
          'gender': emp['gender'],
          'employmentType': emp['employment_type'],
        };
        setState(() {
          _employeeData = data;
          _empScreens = [
            EmployeeDashboard(userData: data),
            PayslipScreen(userData: data),
            AttendanceContent(userData: data),
            ProfileScreen(userData: data),
          ];
          _isEmployeeView = true;
          _empIndex = 0;
        });
      } else if (res.statusCode == 404) {
        _showDialog(
          'Not Found',
          'Your account is not linked to an employee record.\n'
              'Please add yourself to the employees table with the same email (${email}).',
        );
      } else {
        _showDialog('Error', 'Server error: ${res.statusCode}');
      }
    } catch (e) {
      if (mounted)
        _showDialog('Connection Error', 'Could not reach server: $e');
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  void _switchToHrView() => setState(() => _isEmployeeView = false);

  void _showDialog(String title, String msg) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  //toggle widget
  Widget _buildToggle({required bool hrSelected}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Employee pill
          Expanded(
            child: GestureDetector(
              onTap: hrSelected ? _switchToEmployeeView : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:
                      !hrSelected
                          ? const Color(0xFFFBA826)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                alignment: Alignment.center,
                child:
                    _isFetching && hrSelected
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFBA826),
                          ),
                        )
                        : Text(
                          'Employee',
                          style: TextStyle(
                            color:
                                !hrSelected ? Colors.white : Colors.grey[600],
                            fontWeight:
                                !hrSelected ? FontWeight.bold : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
              ),
            ),
          ),
          // HR pill
          Expanded(
            child: GestureDetector(
              onTap: !hrSelected ? _switchToHrView : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:
                      hrSelected ? const Color(0xFFFBA826) : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                alignment: Alignment.center,
                child: Text(
                  'HR',
                  style: TextStyle(
                    color: hrSelected ? Colors.white : Colors.grey[600],
                    fontWeight: hrSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //EMPLOYEE VIEW
    if (_isEmployeeView && _empScreens != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFEBF1F6),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildToggle(
                hrSelected: false,
              ), // "Employee" highlighted; "HR" tappable
              Expanded(
                child: IndexedStack(index: _empIndex, children: _empScreens!),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Nav(
          currentIndex: _empIndex,
          onTabSelected: (i) => setState(() => _empIndex = i),
        ),
      );
    }

    //HR VIEW
    return Scaffold(
      appBar:
          _hrIndex == 0
              ? null
              : AppBar(
                title: Text(
                  _hrIndex == 0
                      ? ''
                      : _hrIndex == 1
                      ? 'Employee Management'
                      : _hrIndex == 2
                      ? 'Attendance History'
                      : 'Settings',
                ),
                backgroundColor: const Color.fromARGB(255, 24, 137, 132),
                foregroundColor: Colors.white,
                centerTitle: true,
                elevation: 0,
              ),
      body: IndexedStack(index: _hrIndex, children: _hrScreens),
      bottomNavigationBar: HrNav(
        currentIndex: _hrIndex,
        onTabSelected: (i) => setState(() => _hrIndex = i),
      ),
    );
  }
}

class AccountantHomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AccountantHomeScreen({super.key, required this.userData});

  @override
  State<AccountantHomeScreen> createState() => _AccountantHomeScreenState();
}

class _AccountantHomeScreenState extends State<AccountantHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      EmployeeDashboard(userData: widget.userData),
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
