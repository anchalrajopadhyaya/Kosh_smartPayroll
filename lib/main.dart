import 'package:flutter/material.dart';
import 'package:payroll/frontend/login.dart';

void main() {
  runApp(const PayrollApp());
}

class PayrollApp extends StatelessWidget {
  const PayrollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Payroll System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const LoginScreen(),
    );
  }
}
