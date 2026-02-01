import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:payroll/frontend/widgets/form_fields.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? dob;
  DateTime? startDate;
  String? department;

  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController jobTitle = TextEditingController();
  final TextEditingController salary = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController district = TextEditingController();
  final TextEditingController province = TextEditingController();
  final TextEditingController ward = TextEditingController();
  final TextEditingController PAN = TextEditingController();
  final TextEditingController citizenshipNo = TextEditingController();
  final TextEditingController password = TextEditingController();

  Future<void> _pickDate(BuildContext context, bool isDob) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        isDob ? dob = date : startDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f9),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 24, 137, 132),
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
        ),
        title: const Text(
          "Add Employee",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Avatar
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          backgroundColor: Color(0xfff0dcd3),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Color.fromARGB(255, 24, 137, 132),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Upload Photo",
                      style: TextStyle(
                        color: Color.fromARGB(255, 24, 137, 132),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _section("PERSONAL INFORMATION"),

              _twoFields(
                _field("First Name", firstName, hint: "first Name"),
                _field("Last Name", lastName, hint: "last name"),
              ),

              _dateField("Date of Birth", dob, () => _pickDate(context, true)),

              _section("CONTACT DETAILS"),
              _field(
                "Email Address",
                email,
                hint: "xx@company.com",
                icon: Icons.email,
              ),

              _field("password", password),

              _field(
                "Phone Number",
                phone,
                hint: "(977) 9841235689",
                icon: Icons.phone,
              ),

              _section("PERMANENT ADDRESS"),
              _twoFields(
                _field("City", city, hint: "Kathmandu"),
                _field("District", district, hint: "Kathmandu"),
              ),

              _twoFields(
                _field("Province", province, hint: "Bagmati"),
                _field("Ward No.", ward, hint: "10"),
              ),

              _field("PAN Number", PAN, hint: "XXXXXX0000"),

              _field("Citizenship Number", citizenshipNo, hint: "XXXXXX0000"),
              _section("JOB & ROLE"),

              _field("Job Title", jobTitle, hint: "Technical Lead"),

              _dropdown(),

              _dateField(
                "Start Date",
                startDate,
                () => _pickDate(context, false),
              ),

              _section("COMPENSATION"),

              _field(
                "Annual Salary",
                salary,
                hint: "\$ 0.00",
                icon: Icons.attach_money,
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text("Create Employee Profile"),
                  onPressed: _createEmployee,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 24, 137, 132),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? hint,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFormLabel(label, color: Colors.blueGrey),
          const SizedBox(height: 6),
          AppInputField(
            controller: controller,
            hint: hint ?? "",
            icon: icon,
            textColor: Colors.black,
            fillColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _twoFields(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget _dateField(String label, DateTime? date, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFormLabel(label, color: Colors.blueGrey),
          const SizedBox(height: 6),
          InkWell(
            onTap: onTap,
            child: InputDecorator(
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.calendar_today),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              child: Text(
                date == null
                    ? "mm/dd/yyyy"
                    : "${date.month}/${date.day}/${date.year}",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppFormLabel("Department", color: Colors.blueGrey),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: department,
            items: const [
              DropdownMenuItem(value: "Accountant", child: Text("Accountant")),
              DropdownMenuItem(value: "Employee", child: Text("Employee")),
              DropdownMenuItem(value: "HR", child: Text("HR")),
            ],
            onChanged: (value) => setState(() => department = value),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse("http://10.0.2.2:3000/api/employees");

    final body = {
      "firstName": firstName.text.trim(),
      "lastName": lastName.text.trim(),
      "email": email.text.trim(),
      "phone": phone.text.trim(),
      "city": city.text.trim(),
      "district": district.text.trim(),
      "province": province.text.trim(),
      "ward": ward.text.trim(),
      "jobTitle": jobTitle.text.trim(),
      "department": department,
      "dob": dob?.toIso8601String(),
      "startDate": startDate?.toIso8601String(),
      "password": password.text.trim(),
      "salary": double.tryParse(salary.text.trim()) ?? 0.0,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Employee created (${data['employeeCode']})")),
        );

        Navigator.pop(context);
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
