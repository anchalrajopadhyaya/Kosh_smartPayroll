// import 'package:flutter/material.dart';
// import 'package:payroll/frontend/navemp.dart';
// import 'package:payroll/frontend/notification.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   int _selectedIndex = 0;

//   void _onNavTap(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff4f6f9),

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Row(
//           children: [
//             CircleAvatar(
//               backgroundImage: AssetImage('assets/profile.jpg'),
//               radius: 16,
//             ),
//             SizedBox(width: 10),
//             Text(
//               "Welcome, 5024",
//               style: TextStyle(
//                 color: Colors.black,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_none, color: Colors.black),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const notification()),
//               );
//             },
//           ),
//           const SizedBox(width: 16),
//         ],
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             //payday card
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "NEXT PAYDAY",
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   const SizedBox(height: 10),
//                   const Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "In 5 days",
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Icon(Icons.arrow_forward_ios, size: 16),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             //leaves section
//             const Text(
//               "Leaves",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),

//             Row(
//               children: [
//                 Expanded(child: _leaveBox("Annual Leave", "12 Days")),
//                 const SizedBox(width: 12),
//                 Expanded(child: _leaveBox("Sick Leave", "5 Days")),
//               ],
//             ),

//             const SizedBox(height: 20),

//             //leave request button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   "Request Leave",
//                   style: TextStyle(fontSize: 16, color: Colors.white),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 25),

//             //recent payslip
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: const [
//                 Text(
//                   "Recent Payslips",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   "View All",
//                   style: TextStyle(color: Colors.blue, fontSize: 14),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//           ],
//         ),
//       ),

//       bottomNavigationBar: Nav(
//         currentIndex: _selectedIndex,
//         onTabSelected: _onNavTap,
//       ),
//     );
//   }

//   Widget _leaveBox(String title, String days) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: const TextStyle(color: Colors.grey)),
//           const SizedBox(height: 8),
//           Text(
//             days,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _payslipTile(String date, String amount) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 date,
//                 style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const Text(
//                 "Net Pay",
//                 style: TextStyle(color: Colors.grey, fontSize: 12),
//               ),
//             ],
//           ),
//           Text(
//             amount,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
// }
