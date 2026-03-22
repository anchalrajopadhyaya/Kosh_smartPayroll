import 'package:flutter/material.dart';

class HrLeaveRequestsScreen extends StatefulWidget {
  const HrLeaveRequestsScreen({super.key});

  @override
  State<HrLeaveRequestsScreen> createState() => _HrLeaveRequestsScreenState();
}

class _HrLeaveRequestsScreenState extends State<HrLeaveRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabBar(),
            const Divider(height: 1, color: Colors.black12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPendingList(),
                  const Center(child: Text("Approved Leaves")),
                  const Center(child: Text("Leave History")),
                ],
              ),
            ),
          ],
        ),
      ),
      // To match the image exactly, we will include the bottom nav bar visually here,
      // but in a real app, it might be handled by the main navigation state.
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Leave Requests',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF141A29),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8EEF8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tune, color: Color(0xFF141A29), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: const Color(0xFF141A29),
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        indicatorColor: const Color(0xFF2B60E6),
        indicatorWeight: 3,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Pending'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2B60E6),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Tab(text: 'Approved'),
          const Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildPendingList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildLeaveCard(
          name: 'Emily Chen',
          role: 'UX Designer',
          imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
          leaveType: 'Sick Leave',
          dateRange: 'Oct 12 - Oct 14, 2023 (3 Days)',
          reason:
              'Feeling unwell since last night, need a few days to recover.',
        ),
        const SizedBox(height: 16),
        _buildLeaveCard(
          name: 'Carlos Ruiz',
          role: 'Marketing Specialist',
          imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
          leaveType: 'Vacation',
          dateRange: 'Nov 1 - Nov 10, 2023 (10 Days)',
          reason: 'Annual family vacation.',
        ),
        const SizedBox(height: 16),
        _buildLeaveCard(
          name: 'Michael Obi',
          role: 'Software Engineer',
          imageUrl: 'https://randomuser.me/api/portraits/men/86.jpg',
          leaveType: 'Personal',
          dateRange: 'Oct 20, 2023 (1 Day)',
          reason: 'Attending a family event out of town.',
        ),
      ],
    );
  }

  Widget _buildLeaveCard({
    required String name,
    required String role,
    required String imageUrl,
    required String leaveType,
    required String dateRange,
    required String reason,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(imageUrl),
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF141A29),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEF8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  leaveType,
                  style: const TextStyle(
                    color: Color(0xFF1A3B8B),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateRange,
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B60E6),
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
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 1, // 'Directory' highlighted in image
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2B60E6),
      unselectedItemColor: Colors.grey[500],
      backgroundColor: Colors.white,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 11,
      ),
      elevation: 20,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          activeIcon: Icon(Icons.grid_view),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.supervisor_account_outlined),
          activeIcon: Icon(Icons.supervisor_account),
          label: 'Directory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payments_outlined),
          activeIcon: Icon(Icons.payments),
          label: 'Payroll',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.manage_accounts_outlined),
          activeIcon: Icon(Icons.manage_accounts),
          label: 'Settings',
        ),
      ],
    );
  }
}
