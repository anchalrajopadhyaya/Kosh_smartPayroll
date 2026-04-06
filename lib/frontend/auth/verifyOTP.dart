import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'reset_password.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter a valid 6-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email, 'otp': otp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ResetPasswordScreen(email: widget.email, otp: otp),
          ),
        );
      } else {
        setState(() => _errorMessage = data['message'] ?? 'Invalid OTP');
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
        title: const Text('Verify OTP'),
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
              Icons.mark_email_read,
              size: 80,
              color: Color.fromARGB(255, 24, 137, 132),
            ),
            const SizedBox(height: 24),
            Text(
              'Enter the 6-digit code sent to ${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'OTP Code',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.password),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
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
              onPressed: _isLoading ? null : verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 24, 137, 132),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Verify', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
