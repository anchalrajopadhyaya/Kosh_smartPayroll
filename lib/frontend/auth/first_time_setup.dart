import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:payroll/frontend/state/statemngNav.dart';

class FirstTimeSetupScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String userType;

  const FirstTimeSetupScreen({
    super.key,
    required this.userData,
    required this.userType,
  });

  @override
  State<FirstTimeSetupScreen> createState() => _FirstTimeSetupScreenState();
}

class _FirstTimeSetupScreenState extends State<FirstTimeSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  late final TextEditingController _phoneController;

  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill phone number if available (exclusive to employee/accountant roles)
    _phoneController = TextEditingController(text: widget.userData['phone']);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitSetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final isEmployee = widget.userType != 'hr';
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/first-time-setup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.userData['email'],
          'newPassword': _passwordController.text,
          'phone': isEmployee ? _phoneController.text.trim() : null,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;

        final resolvedType = data['userType'] as String;
        final userData = data['user'] as Map<String, dynamic>;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account configured successfully! Welcome.'),
            backgroundColor: Colors.green,
          ),
        );

        // Auto-login: Route straight to correct home dashboard screen
        if (resolvedType == 'hr') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HrHomeScreen(userData: userData)),
          );
        } else if (resolvedType == 'accountant') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AccountantHomeScreen(userData: userData),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(userData: userData)),
          );
        }
      } else {
        setState(() {
          _errorMessage =
              data['message'] ?? 'Failed to complete first-time setup.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmployee = widget.userType != 'hr';

    return Scaffold(
      backgroundColor: const Color(0xfff4f6f9),
      appBar: AppBar(
        title: const Text('Account Setup'),
        backgroundColor: const Color.fromARGB(255, 24, 137, 132),
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading:
            false, // Prevents navigating back during required setup
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF188984)),
              )
              : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.security_rounded,
                          size: 80,
                          color: Color(0xFF188984),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'First-Time Login Setup',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F6E6E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'For security, you must update your password and verify your details before accessing the system.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 30),

                        // New Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed:
                                  () => setState(
                                    () => _obscureText = !_obscureText,
                                  ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_reset),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (val) {
                            if (val != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Phone Number (Only show if Employee / Accountant)
                        if (isEmployee) ...[
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Confirm Phone Number',
                              prefixIcon: const Icon(Icons.phone_android),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter and confirm your phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                        ],

                        if (_errorMessage.isNotEmpty) ...[
                          Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                        ],

                        ElevatedButton(
                          onPressed: _submitSetup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF188984),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Confirm & Complete Setup',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
}
