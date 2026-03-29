import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HrTimeRequestsScreen extends StatefulWidget {
  const HrTimeRequestsScreen({super.key});

  @override
  State<HrTimeRequestsScreen> createState() => _HrTimeRequestsScreenState();
}

class _HrTimeRequestsScreenState extends State<HrTimeRequestsScreen> {
  int _selectedTabIndex = 0;
  bool _isLoading = true;
  List<dynamic> _timeRequests = [];

  final List<String> _tabs = ['Pending', 'Approved', 'History'];

  @override
  void initState() {
    super.initState();
    _fetchTimeRequests();
  }

  Future<void> _fetchTimeRequests() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/time-request/all'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _timeRequests = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error fetching time requests: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateTimeRequestStatus(int id, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/api/time-request/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      );
      if (response.statusCode == 200) {
        _fetchTimeRequests(); // Refresh list after update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request $newStatus successfully!'),
            backgroundColor:
                newStatus == 'Approved' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<dynamic> get _filteredRequests {
    if (_selectedTabIndex == 0) {
      return _timeRequests.where((r) => r['status'] == 'Pending').toList();
    } else if (_selectedTabIndex == 1) {
      return _timeRequests.where((r) => r['status'] == 'Approved').toList();
    } else {
      return _timeRequests.where((r) => r['status'] == 'Declined').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF1F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCustomTabBar(),
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF188984),
                        ),
                      )
                      : _filteredRequests.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _filteredRequests.length,
                        itemBuilder: (context, index) {
                          return _buildRequestCard(_filteredRequests[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF141A29)),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Time Requests',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF141A29),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tune, color: Color(0xFF141A29), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: List.generate(
          _tabs.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color:
                      _selectedTabIndex == index
                          ? const Color(0xFF141A29)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    color:
                        _selectedTabIndex == index
                            ? Colors.white
                            : Colors.grey[500],
                    fontWeight:
                        _selectedTabIndex == index
                            ? FontWeight.bold
                            : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No ${_tabs[_selectedTabIndex]} Requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(dynamic requestData) {
    final String employeeName =
        "${requestData['employee']['first_name']} ${requestData['employee']['last_name']}";
    final String requestType = requestData['request_type'] ?? 'Adjustment';
    final String date = DateFormat(
      'MMM dd, yyyy',
    ).format(DateTime.parse(requestData['date']));

    final String? timeIn = requestData['time_in'];
    final String? timeOut = requestData['time_out'];
    String timeDisplay = "No time specified";
    if (timeIn != null && timeOut != null) {
      timeDisplay = "In: $timeIn  •  Out: $timeOut";
    } else if (timeIn != null) {
      timeDisplay = "In: $timeIn";
    } else if (timeOut != null) {
      timeDisplay = "Out: $timeOut";
    }

    final String reason = requestData['reason'] ?? 'No reason provided';
    final int id = requestData['id'];
    final String status = requestData['status'];

    final colorMap = {
      'Late Check-in': const Color(0xFFFBA826),
      'Missed Check-in': const Color(0xFFF45E5E),
      'Early Check-out': const Color(0xFFFBA826),
    };

    final requestColor = colorMap[requestType] ?? const Color(0xFF188984);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(employeeName)}&background=random',
                  ),
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employeeName,
                        style: const TextStyle(
                          color: Color(0xFF141A29),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: requestColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          requestType,
                          style: TextStyle(
                            color: requestColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color:
                        status == 'Pending'
                            ? const Color(0xFFFBA826)
                            : (status == 'Approved'
                                ? Colors.green
                                : Colors.red),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEBF1F6)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$date | $timeDisplay",
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  reason,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (status == 'Pending')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateTimeRequestStatus(id, 'Declined'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.black12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Decline',
                        style: TextStyle(
                          color: Color(0xFF141A29),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateTimeRequestStatus(id, 'Approved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF188984),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Approve',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
