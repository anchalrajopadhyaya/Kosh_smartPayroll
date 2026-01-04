// // add_employee_screen.dart
// import 'package:flutter/material.dart';

// class AddEmployeeScreen extends StatefulWidget {
//   const AddEmployeeScreen({super.key});
//   @override
//   State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
// }

// class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _saveEmployee() {
//     if (_formKey.currentState!.validate()) {
//       // TODO: send these to your backend / auth service
//       // _nameController.text
//       // _emailController.text
//       // _usernameController.text
//       // _passwordController.text
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Employee created successfully')),
//       );
//       Navigator.pop(context); // Back to EmployeeScreen
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Employee')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(labelText: 'Full Name'),
//                 validator:
//                     (v) =>
//                         v == null || v.isEmpty ? 'Enter employee name' : null,
//               ),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(labelText: 'Email'),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Login Credentials',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               TextFormField(
//                 controller: _usernameController,
//                 decoration: const InputDecoration(labelText: 'Username'),
//                 validator:
//                     (v) => v == null || v.isEmpty ? 'Enter username' : null,
//               ),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(labelText: 'Password'),
//                 obscureText: true,
//                 validator:
//                     (v) =>
//                         v == null || v.length < 6 ? 'Min 6 characters' : null,
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _saveEmployee,
//                   child: const Text('Save Employee'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
