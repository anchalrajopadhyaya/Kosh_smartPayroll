import 'package:flutter/material.dart';
import 'empAdd.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key});

  static const Color primaryColor = Color.fromARGB(255, 24, 137, 132);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      body: const Center(child: Text('Employee list will go here')),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEmployeeScreen()),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Employee'),
      ),
    );
  }
}
