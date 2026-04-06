import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:payroll/frontend/auth/verifyOTP.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyOtpScreen(email: email),
          ),
        );
      } else {
        setState(() => _errorMessage = data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f9),
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: const Color.fromARGB(255, 24, 137, 132),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.lock_reset,
              size: 80,
              color: Color.fromARGB(255, 24, 137, 132),
            ),
            const SizedBox(height: 24),
            const Text(
              'Enter your email address to receive a 6-digit verification code.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 24, 137, 132),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Send Code', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
