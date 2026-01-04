// // employee_screen.dart
// import 'package:flutter/material.dart';
// import 'empAdd.dart';

// class EmployeeScreen extends StatelessWidget {
//   const EmployeeScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Employees')),
//       body: const Center(child: Text('Employee list will go here')),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const EmployeeScreen()),
//           );
//         },
//         icon: const Icon(Icons.person_add),
//         label: const Text('Add Employee'),
//       ),
//     );
//   }
// }
