import 'package:flutter/material.dart';
import 'UICard.dart';
import 'empDetails.dart';

class HrDashboardScreen extends StatelessWidget {
  final String userName;
  final VoidCallback? onEmployeesTap;

  const HrDashboardScreen({
    required this.userName,
    this.onEmployeesTap,
    super.key,
  });

  static const Color primaryColor = Color.fromARGB(255, 24, 137, 132);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xfff4f6f9),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                DashboardCard(
                  title: 'Employees',
                  value: '120',
                  icon: Icons.people,
                  color: Colors.blue,
                  onTap:
                      onEmployeesTap ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EmployeeScreen(),
                          ),
                        );
                      },
                ),
                const DashboardCard(
                  title: 'Attendance',
                  value: '95%',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                const DashboardCard(
                  title: 'Leave Requests',
                  value: '8',
                  icon: Icons.event_note,
                  color: Colors.orange,
                ),
                const DashboardCard(
                  title: 'Departments',
                  value: '6',
                  icon: Icons.apartment,
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hello, $userName",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Text(
          "Here's what's happening today",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }
}
