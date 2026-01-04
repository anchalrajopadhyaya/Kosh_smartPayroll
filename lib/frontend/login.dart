import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'hr_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    // final url = Uri.parse('http://10.0.2.2:3000/login');
    final url = Uri.parse('http://192.168.50.116:3000/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _employeeIdController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      print('FULL RESPONSE:');
      print('Status: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = response.body;
        if (body.isEmpty) {
          setState(() => _error = 'Empty response from server');
          return;
        }

        try {
          final data = jsonDecode(body) as Map<String, dynamic>;
          print('Parsed data: $data');

          final userData = data['user'] as Map<String, dynamic>?;
          if (userData == null) {
            setState(() => _error = 'Missing user data in response');
            return;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
                      HrDashboardScreen(userName: userData['name'] ?? 'User'),
            ),
          );
        } catch (e) {
          print('JSON parse error: $e');
          setState(() => _error = 'Invalid server response: $e');
        }
      } else if (response.statusCode == 401) {
        setState(() => _error = 'Invalid email or password');
      } else {
        setState(
          () =>
              _error = 'Server error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not connect to server: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 24, 137, 132),
              Color.fromARGB(255, 1, 24, 24),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // Logo
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Center(
                    child: Text(
                      "Logo",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  "Welcome to Kosh",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Smart Payroll Management",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 36),

                // Employee Email
                _label("Email"),
                const SizedBox(height: 8),
                _inputField(
                  controller: _employeeIdController,
                  hint: "Enter your email",
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 20),

                // Password
                _label("Password"),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText:
                      !_isPasswordVisible, // Corrected: Toggle based on visibility
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    hintStyle: const TextStyle(color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons
                                .visibility_off // Eye closed when visible (to hide)
                            : Icons
                                .visibility, // Eye open when hidden (to show)
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white.withAlpha(46),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),

                const SizedBox(height: 16),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 230, 226, 226),
                      foregroundColor: const Color(0xFF0F6E6E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Color(0xFF0F6E6E),
                            )
                            : const Text(
                              "Log In",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 18),

                // Forgot Password
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        suffixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withAlpha(46),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
