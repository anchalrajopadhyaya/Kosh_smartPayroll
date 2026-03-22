import 'package:flutter/material.dart';

class HrNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const HrNav({
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
      selectedItemColor: const Color(0xFFFBA826),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 11,
      ),
      elevation: 20,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          activeIcon: Icon(Icons.grid_view),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.supervisor_account_outlined),
          activeIcon: Icon(Icons.supervisor_account),
          label: 'Directory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payments_outlined),
          activeIcon: Icon(Icons.payments),
          label: 'Payroll',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.manage_accounts_outlined),
          activeIcon: Icon(Icons.manage_accounts),
          label: 'Settings',
        ),
      ],
    );
  }
}
