import 'package:flutter/material.dart';

class AccountantNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const AccountantNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabSelected,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF188984),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 10,
      ),
      elevation: 20,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Payslips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time_outlined),
          activeIcon: Icon(Icons.access_time),
          label: 'Attendance',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insert_chart_outlined),
          activeIcon: Icon(Icons.insert_chart),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
