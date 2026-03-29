import 'package:flutter/material.dart';
import 'package:payroll/frontend/HR/hr_feedback.dart';
import 'package:payroll/frontend/HR/hr_leave_requests.dart';
import 'package:payroll/frontend/HR/hr_timerequest.dart';
import 'empAdd.dart';

class HrDashboardScreen extends StatelessWidget {
  final String userName;
  final VoidCallback? onEmployeesTap;

  const HrDashboardScreen({
    required this.userName,
    this.onEmployeesTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF1F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildTopToggle(),
              const SizedBox(height: 24),
              _buildProfileRow(),
              const SizedBox(height: 24),
              _buildStatsCard(),
              const SizedBox(height: 24),
              _buildActionRow(context),
              const SizedBox(height: 24),
              _buildPendingApprovalsHeader(),
              const SizedBox(height: 16),
              _buildPendingApprovalsList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleOption('Employee', false)),
          Expanded(child: _buildToggleOption('HR', true)),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFBA826) : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildProfileRow() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundImage: const NetworkImage(
            'https://randomuser.me/api/portraits/women/44.jpg',
          ),
          backgroundColor: Colors.grey[300],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good morning,",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              userName,
              style: const TextStyle(
                color: Color(0xFF141927),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none,
                color: Colors.black87,
              ),
            ),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 24, 137, 132),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.people_alt_outlined,
              size: 140,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Active Employees',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '1,248',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'New Hires This Month: 12',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '+4.2%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(Icons.person_add_alt_1_outlined, 'Add Staff', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
          );
        }),
        _buildActionItem(Icons.edit_calendar_outlined, 'Leave Req', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HrLeaveRequestsScreen(),
            ),
          );
        }),
        _buildActionItem(Icons.access_time, 'Timesheets', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HrTimeRequestsScreen(),
            ),
          );
        }),
        _buildActionItem(Icons.feedback_outlined, 'Feedback', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HrFeedbackScreen()),
          );
        }),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF141A29), size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'Pending Approvals',
          style: TextStyle(
            color: Color(0xFF141927),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'View All (8)',
          style: TextStyle(
            color: const Color(0xFFFBA826),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingApprovalsList() {
    return Column(
      children: [
        _buildApprovalItem(name: 'Michael Chen', type: 'Annual Leave (3 Days)'),
        const SizedBox(height: 12),
        _buildApprovalItem(name: 'Jessica Davis', type: 'Sick Leave (1 Day)'),
        const SizedBox(height: 12),
        _buildApprovalItem(name: 'Carlos Rodriguez', type: 'Profile Update'),
      ],
    );
  }

  Widget _buildApprovalItem({required String name, required String type}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: Colors.grey[300]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF141927),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  type,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
          _buildCircleButton(icon: Icons.close, color: const Color(0xFFF45E5E)),
          const SizedBox(width: 8),
          _buildCircleButton(icon: Icons.check, color: const Color(0xFF1FB45C)),
        ],
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}
