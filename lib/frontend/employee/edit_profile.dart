import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;
  const EditProfileScreen({super.key, required this.profileData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal Info fields
  late final TextEditingController _cityController;
  late final TextEditingController _districtController;
  late final TextEditingController _provinceController;
  late final TextEditingController _wardController;
  String? _selectedGender;
  String? _selectedMaritalStatus;

  // Legal Info fields (requires approval)
  late final TextEditingController _phoneController;
  late final TextEditingController _panController;
  late final TextEditingController _citizenshipNoController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialize personal info
    _cityController = TextEditingController(text: widget.profileData['city']);
    _districtController = TextEditingController(
      text: widget.profileData['district'],
    );
    _provinceController = TextEditingController(
      text: widget.profileData['province'],
    );
    _wardController = TextEditingController(
      text: widget.profileData['ward']?.toString(),
    );
    final gender =
        widget.profileData['gender']?.toString().trim().toLowerCase();
    if (gender == 'male') {
      _selectedGender = 'Male';
    } else if (gender == 'female') {
      _selectedGender = 'Female';
    } else if (gender == 'other') {
      _selectedGender = 'Other';
    } else {
      _selectedGender = 'Other';
    }

    final marital =
        widget.profileData['marital_status']?.toString().trim().toLowerCase();
    if (marital == 'unmarried' ||
        marital == 'married' ||
        marital == 'divorced' ||
        marital == 'widowed') {
      _selectedMaritalStatus = marital;
    } else {
      _selectedMaritalStatus = 'unmarried';
    }

    // Initialize legal info
    _phoneController = TextEditingController(text: widget.profileData['phone']);
    _panController = TextEditingController(text: widget.profileData['pan']);
    _citizenshipNoController = TextEditingController(
      text: widget.profileData['citizenship_no'],
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    _districtController.dispose();
    _provinceController.dispose();
    _wardController.dispose();
    _phoneController.dispose();
    _panController.dispose();
    _citizenshipNoController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final employeeId = widget.profileData['id'];

      // Check if personal info has changed
      final personalChanged =
          _cityController.text.trim() != (widget.profileData['city'] ?? '') ||
          _districtController.text.trim() !=
              (widget.profileData['district'] ?? '') ||
          _provinceController.text.trim() !=
              (widget.profileData['province'] ?? '') ||
          _wardController.text.trim() !=
              (widget.profileData['ward']?.toString() ?? '') ||
          _selectedGender != (widget.profileData['gender'] ?? 'Other') ||
          _selectedMaritalStatus !=
              (widget.profileData['marital_status'] ?? 'unmarried');

      // Check if legal info has changed
      final legalChanged =
          _phoneController.text.trim() != (widget.profileData['phone'] ?? '') ||
          _panController.text.trim() != (widget.profileData['pan'] ?? '') ||
          _citizenshipNoController.text.trim() !=
              (widget.profileData['citizenship_no'] ?? '');

      bool personalSuccess = true;
      bool legalSuccess = true;

      // 1. Update personal info directly if changed
      if (personalChanged) {
        final res = await http.put(
          Uri.parse(
            'http://10.0.2.2:3000/api/profile-update/personal-info/$employeeId',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'city': _cityController.text.trim(),
            'district': _districtController.text.trim(),
            'province': _provinceController.text.trim(),
            'ward': _wardController.text.trim(),
            'maritalStatus': _selectedMaritalStatus?.toLowerCase(),
            'gender': _selectedGender?.toLowerCase(),
          }),
        );
        personalSuccess = res.statusCode == 200;
      }

      // 2. Submit request for legal info if changed
      if (legalChanged) {
        final res = await http.post(
          Uri.parse('http://10.0.2.2:3000/api/profile-update'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'employeeId': employeeId,
            'phone': _phoneController.text.trim(),
            'pan': _panController.text.trim(),
            'citizenshipNo': _citizenshipNoController.text.trim(),
          }),
        );
        legalSuccess = res.statusCode == 201;
      }

      if (mounted) {
        setState(() => _isSaving = false);
        if (personalSuccess && legalSuccess) {
          String message = "Information updated successfully.";
          if (legalChanged) {
            message =
                "Personal details updated. Legal info changes submitted for HR approval.";
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Return true to trigger refresh
        } else {
          throw "Failed to update profile values. Please try again.";
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF1F6),
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body:
          _isSaving
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF188984)),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- PERSONAL INFORMATION ---
                      _buildSectionHeader("Personal Information", Icons.person),
                      const SizedBox(height: 8),
                      _buildCard([
                        _buildDropdownField(
                          label: "Gender",
                          value: _selectedGender,
                          items: ['Male', 'Female', 'Other'],
                          onChanged:
                              (val) => setState(() => _selectedGender = val),
                        ),
                        _buildDropdownField(
                          label: "Marital Status",
                          value: _selectedMaritalStatus,
                          items: [
                            'unmarried',
                            'married',
                            'divorced',
                            'widowed',
                          ],
                          onChanged:
                              (val) =>
                                  setState(() => _selectedMaritalStatus = val),
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // --- ADDRESS ---
                      _buildSectionHeader("Address Details", Icons.location_on),
                      const SizedBox(height: 8),
                      _buildCard([
                        _buildTextField(
                          label: "Province",
                          controller: _provinceController,
                        ),
                        _buildTextField(
                          label: "District",
                          controller: _districtController,
                        ),
                        _buildTextField(
                          label: "City",
                          controller: _cityController,
                        ),
                        _buildTextField(
                          label: "Ward",
                          controller: _wardController,
                          keyboardType: TextInputType.number,
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // --- LEGAL INFORMATION ---
                      _buildSectionHeader(
                        "Legal Information (Requires HR Approval)",
                        Icons.gavel,
                        isAlert: true,
                      ),
                      const SizedBox(height: 8),
                      _buildCard([
                        _buildTextField(
                          label: "Phone Number",
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildTextField(
                          label: "PAN",
                          controller: _panController,
                        ),
                        _buildTextField(
                          label: "Citizenship Number",
                          controller: _citizenshipNoController,
                        ),
                      ]),
                      const SizedBox(height: 30),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF188984),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    bool isAlert = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isAlert ? Colors.orange : const Color(0xFF188984),
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isAlert ? Colors.orange.shade800 : const Color(0xFF0F6E6E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF188984)),
        ),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return "$label cannot be empty";
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF188984)),
        ),
      ),
    );
  }
}
