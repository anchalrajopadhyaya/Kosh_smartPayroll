import 'package:flutter/material.dart';
import 'UICard.dart';
import 'empDetails.dart';

class HrDashboardScreen extends StatelessWidget {
  final String userName;
  const HrDashboardScreen({required this.userName, super.key});
  static const Color primaryColor = Color.fromARGB(255, 24, 137, 132);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $userName'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            DashboardCard(
              title: 'Employees',
              value: '120',
              icon: Icons.people,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeScreen()),
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
      ),
    );
  }
}
