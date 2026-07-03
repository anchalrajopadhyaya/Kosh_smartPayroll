import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HrProfileRequestsScreen extends StatefulWidget {
  const HrProfileRequestsScreen({super.key});

  @override
  State<HrProfileRequestsScreen> createState() =>
      _HrProfileRequestsScreenState();
}

class _HrProfileRequestsScreenState extends State<HrProfileRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/profile-update/pending'),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _requests = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      } else {
        throw 'Failed to load profile requests';
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

  Future<void> _updateRequestStatus(int requestId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/api/profile-update/$requestId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        _fetchRequests(); // Refresh the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Request $status successfully!'),
              backgroundColor: status == 'Approved' ? Colors.green : Colors.red,
            ),
          );
        }
      } else {
        throw 'Failed to update request: ${response.statusCode}';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF1F6),
      appBar: AppBar(
        title: const Text('Profile Update Requests'),
        backgroundColor: const Color.fromARGB(255, 24, 137, 132),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF188984)),
              )
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: $_error',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchRequests,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF188984),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
              : _requests.isEmpty
              ? const Center(
                child: Text(
                  'No pending profile update requests.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  final req = _requests[index];
                  final int id = req['id'];
                  final employee = req['employee'];
                  final String empName =
                      employee != null
                          ? "${employee['first_name'] ?? ''} ${employee['last_name'] ?? ''}"
                              .trim()
                          : "Employee #${req['employee_id']}";

                  // Build changes list
                  final List<Widget> changes = [];
                  if (req['phone'] != null) {
                    changes.add(
                      _buildChangeRow(
                        "Phone",
                        req['phone'],
                        employee?['phone'],
                      ),
                    );
                  }
                  if (req['pan'] != null) {
                    changes.add(
                      _buildChangeRow("PAN", req['pan'], employee?['pan']),
                    );
                  }
                  if (req['citizenship_no'] != null) {
                    changes.add(
                      _buildChangeRow(
                        "Citizenship No.",
                        req['citizenship_no'],
                        employee?['citizenship_no'],
                      ),
                    );
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Color(0xFF188984),
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      empName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF0F6E6E),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Requested on: ${_formatDate(req['created_at'])}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          const Text(
                            "Proposed Legal Info Changes:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...changes,
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed:
                                    () => _updateRequestStatus(id, "Declined"),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                label: const Text(
                                  "Decline",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed:
                                    () => _updateRequestStatus(id, "Approved"),
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                label: const Text(
                                  "Approve",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1FB45C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildChangeRow(String label, String newValue, String? currentValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: newValue,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text:
                  currentValue != null && currentValue.trim().isNotEmpty
                      ? "  (was: $currentValue)"
                      : "  (was: N/A)",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return dateStr;
    }
  }
}
