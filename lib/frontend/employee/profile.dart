import 'package:payroll/frontend/utils/config.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:payroll/frontend/login.dart';
import 'package:payroll/frontend/employee/edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfileDetails();
  }

  Future<void> _fetchProfileDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(
        Uri.parse(
          '${AppConfig.baseUrl}/api/employees/${widget.userData['id']}',
        ),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _profileData = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      } else {
        throw 'Failed to load profile details (Status: ${response.statusCode})';
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF1F6),
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions:
            _isLoading || _error != null || _profileData == null
                ? null
                : [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF188984)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  EditProfileScreen(profileData: _profileData!),
                        ),
                      ).then((updated) {
                        if (updated == true) {
                          _fetchProfileDetails();
                        }
                      });
                    },
                  ),
                ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF188984)),
              )
              : _error != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 12),
                      Text("Error: $_error", textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchProfileDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF188984),
                        ),
                        child: const Text(
                          "Retry",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Avatar
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF188984),
                        child: Text(
                          (_profileData?['first_name'] ?? 'E')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "${_profileData?['first_name'] ?? ''} ${_profileData?['last_name'] ?? ''}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _profileData?['job_title'] ?? 'Employee',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 30),

                    // Info Cards
                    _buildInfoCard(
                      Icons.badge,
                      "Employee Code",
                      _profileData?['employee_code'],
                    ),
                    _buildInfoCard(
                      Icons.email,
                      "Email",
                      _profileData?['email'],
                    ),
                    _buildInfoCard(
                      Icons.phone,
                      "Phone (Legal Info)",
                      _profileData?['phone'],
                    ),
                    _buildInfoCard(
                      Icons.credit_card,
                      "PAN (Legal Info)",
                      _profileData?['pan'],
                    ),
                    _buildInfoCard(
                      Icons.assignment_ind,
                      "Citizenship No. (Legal Info)",
                      _profileData?['citizenship_no'],
                    ),
                    _buildInfoCard(
                      Icons.business,
                      "Department",
                      _profileData?['department'],
                    ),
                    _buildInfoCard(
                      Icons.monetization_on,
                      "Salary",
                      _profileData?['salary'] != null
                          ? "NPR ${_profileData?['salary']}"
                          : 'N/A',
                    ),
                    _buildInfoCard(
                      Icons.location_on,
                      "Address",
                      _buildAddressString(),
                    ),
                    _buildInfoCard(
                      Icons.favorite,
                      "Marital Status",
                      _profileData?['marital_status'],
                    ),
                    _buildInfoCard(Icons.wc, "Gender", _profileData?['gender']),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          if (context.mounted) {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
    );
  }

  String _buildAddressString() {
    final profile = _profileData;
    if (profile == null) return 'N/A';

    final list = [
      if (profile['ward'] != null &&
          profile['ward'].toString().trim().isNotEmpty == true)
        "Ward ${profile['ward']}",
      if (profile['city'] != null &&
          profile['city'].toString().trim().isNotEmpty == true)
        profile['city'].toString(),
      if (profile['district'] != null &&
          profile['district'].toString().trim().isNotEmpty == true)
        profile['district'].toString(),
      if (profile['province'] != null &&
          profile['province'].toString().trim().isNotEmpty == true)
        profile['province'].toString(),
    ];
    return list.isEmpty ? 'N/A' : list.join(', ');
  }

  Widget _buildInfoCard(IconData icon, String title, String? value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF188984)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        subtitle: Text(
          value ?? 'N/A',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
