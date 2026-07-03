import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class notification extends StatefulWidget {
  final Map<String, dynamic> userData;

  const notification({super.key, required this.userData});

  @override
  State<notification> createState() => _NotificationState();
}

class _NotificationState extends State<notification> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final isHr = widget.userData['role']?.toString().toLowerCase() == 'hr';
      final employeeId = widget.userData['id'];
      final url =
          isHr
              ? 'http://10.0.2.2:3000/api/notifications/hr'
              : 'http://10.0.2.2:3000/api/notifications/$employeeId';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _notifications = data;
            _isLoading = false;
          });
        }
      } else {
        throw 'Failed to load notifications: ${response.statusCode}';
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

  Future<void> _markAsRead(int notificationId) async {
    try {
      final response = await http.put(
        Uri.parse(
          'http://10.0.2.2:3000/api/notifications/$notificationId/read',
        ),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            final index = _notifications.indexWhere(
              (n) => n['id'] == notificationId,
            );
            if (index != -1) {
              _notifications[index]['is_read'] = true;
            }
          });
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF188984),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color(0x1E8AE7FF),
        child: RefreshIndicator(
          onRefresh: _fetchNotifications,
          child:
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
                            onPressed: _fetchNotifications,
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
                  : _notifications.isEmpty
                  ? const Center(
                    child: Text(
                      "No notifications yet.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      final int id = notif['id'];
                      final String title = notif['title'] ?? 'No Title';
                      final String description = notif['description'] ?? '';
                      final bool isRead = notif['is_read'] ?? false;

                      return NotificationCard(
                        title: title,
                        description: description,
                        isRead: isRead,
                        onTap: () {
                          if (!isRead) {
                            _markAsRead(id);
                          }
                          _showNotificationDetails(context, title, description);
                        },
                      );
                    },
                  ),
        ),
      ),
    );
  }

  void _showNotificationDetails(
    BuildContext context,
    String title,
    String description,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.notifications_active, color: Color(0xFF188984)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F6E6E),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              description,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFF188984),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isRead;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isRead ? 1 : 3,
      color: isRead ? Colors.white : const Color(0xFFF1FAF9),
      child: ListTile(
        leading: Icon(
          isRead ? Icons.notifications_none : Icons.notifications_active,
          color: const Color(0xFF188984),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            color: isRead ? Colors.black87 : const Color(0xFF0F6E6E),
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
            color: isRead ? Colors.grey.shade600 : Colors.black87,
          ),
        ),
        trailing:
            !isRead
                ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                )
                : const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
        onTap: onTap,
      ),
    );
  }
}
