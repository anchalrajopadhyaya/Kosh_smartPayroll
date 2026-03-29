import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HrFeedbackScreen extends StatefulWidget {
  const HrFeedbackScreen({super.key});

  @override
  State<HrFeedbackScreen> createState() => _HrFeedbackScreenState();
}

class _HrFeedbackScreenState extends State<HrFeedbackScreen> {
  int _selectedTabIndex = 0;
  bool _isLoading = true;
  List<dynamic> _feedbacks = [];

  final List<String> _tabs = ['Unread', 'Reviewed', 'Resolved'];

  @override
  void initState() {
    super.initState();
    _fetchFeedbacks();
  }

  Future<void> _fetchFeedbacks() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/feedback/all'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _feedbacks = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error fetching feedbacks: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateFeedbackStatus(int id, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/api/feedback/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      );
      if (response.statusCode == 200) {
        _fetchFeedbacks(); // Refresh list after update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marked as $newStatus!'),
            backgroundColor:
                newStatus == 'Resolved' ? Colors.green : Colors.blue,
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

  List<dynamic> get _filteredFeedbacks {
    if (_selectedTabIndex == 0) {
      return _feedbacks.where((r) => r['status'] == 'Unread').toList();
    } else if (_selectedTabIndex == 1) {
      return _feedbacks.where((r) => r['status'] == 'Reviewed').toList();
    } else {
      return _feedbacks.where((r) => r['status'] == 'Resolved').toList();
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
                      : _filteredFeedbacks.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _filteredFeedbacks.length,
                        itemBuilder: (context, index) {
                          return _buildFeedbackCard(_filteredFeedbacks[index]);
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
                'Anonymous Feedback',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF141A29),
                ),
              ),
            ],
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
            'No ${_tabs[_selectedTabIndex]} Feedback',
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

  Widget _buildFeedbackCard(dynamic feedback) {
    final String category = feedback['category'] ?? 'General';
    final String date = DateFormat(
      'MMM dd, yyyy - hh:mm a',
    ).format(DateTime.parse(feedback['created_at']));
    final String message = feedback['message'];
    final int id = feedback['id'];
    final String status = feedback['status'];

    final colorMap = {
      'Suggestion': const Color(0xFF188984),
      'Complaint': const Color(0xFFF45E5E),
      'Question': const Color(0xFFFBA826),
      'General': Colors.grey,
    };

    final categoryColor = colorMap[category] ?? Colors.grey;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: categoryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color:
                        status == 'Unread'
                            ? const Color(0xFFFBA826)
                            : (status == 'Reviewed'
                                ? Colors.blue
                                : Colors.green),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF141A29),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (status != 'Resolved') ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  if (status == 'Unread')
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateFeedbackStatus(id, 'Reviewed'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Mark Reviewed',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (status == 'Unread') const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateFeedbackStatus(id, 'Resolved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Mark Resolved',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
