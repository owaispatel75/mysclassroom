// import 'package:flutter/material.dart';

// class DashboardScreen extends StatefulWidget {
//   final String role; // 'teacher' | 'student' | 'admin'
//   const DashboardScreen({super.key, required this.role});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   int _index = 0;
//   late final List<_TabDef> tabs;

//   @override
//   void initState() {
//     super.initState();
//     tabs = _buildTabs(widget.role);
//   }

//   List<_TabDef> _buildTabs(String role) {
//     final t = <_TabDef>[];
//     t.add(_TabDef('Classroom', const Placeholder())); // all roles
//     if (role == 'student' || role == 'admin') {
//       t.add(_TabDef('Payments', const Placeholder()));
//     }
//     if (role == 'admin') {
//       t.add(_TabDef('Reports', const Placeholder()));
//     }
//     t.add(_TabDef('Profile', const Placeholder())); // all roles
//     return t;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Dashboard (${widget.role})')),
//       body: tabs[_index].screen,
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _index,
//         onTap: (i) => setState(() => _index = i),
//         items: [
//           for (final t in tabs)
//             BottomNavigationBarItem(
//               icon: const Icon(Icons.circle),
//               label: t.title,
//             ),
//         ],
//       ),
//     );
//   }
// }

// class _TabDef {
//   final String title;
//   final Widget screen;
//   _TabDef(this.title, this.screen);
// }

//working starts
// import 'package:classroom_frontend/payment_screen.dart';
// import 'package:classroom_frontend/profile_screen.dart';
// import 'package:classroom_frontend/subject_screen.dart';
// import 'package:flutter/material.dart';
// // import 'package:online_classes/core/constants/app_colors.dart';
// // import 'package:online_classes/core/constants/app_sizedboxes.dart';
// // import 'package:online_classes/features/dashboard/presentation/page1.dart';

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   Widget buildCard({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Card(
//         elevation: 5,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 50, color: Colors.teal[300]),
//               // Icon(icon, size: 50, color: AppColors.app_bar_color),
//               SizedBox(height: 10),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text("Dashboard"),
//         // backgroundColor: AppColors.app_bar_color,
//         backgroundColor: Colors.teal,
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(12),
//         // color: AppColors.bgColor,
//         color: Colors.teal[300],
//         child: GridView.count(
//           crossAxisCount: 2,
//           crossAxisSpacing: 12,
//           mainAxisSpacing: 12,
//           children: [
//             buildCard(
//               icon: Icons.school_rounded,
//               title: "Classroom",
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const SubjectListScreen(),
//                   ),
//                 );
//               },
//             ),
//             buildCard(
//               icon: Icons.payment_rounded,
//               title: "Payments",
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const PaymentScreen(),
//                   ),
//                 );
//                 // Navigate to payments page
//               },
//             ),
//             buildCard(
//               icon: Icons.bar_chart_rounded,
//               title: "Reports",
//               onTap: () {
//                 // Navigate to reports page
//               },
//             ),
//             buildCard(
//               icon: Icons.person_rounded,
//               title: "Profile",
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const ProfileScreen(),
//                   ),
//                 );
//                 // Navigate to profile page
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//working ends

import 'package:classroom_frontend/admin_classroom_screen.dart';
import 'package:classroom_frontend/admin_reports_screen.dart';
import 'package:classroom_frontend/admin_subjects_screen.dart';
import 'package:classroom_frontend/admin_users_screen.dart';
import 'package:flutter/material.dart';
import 'package:classroom_frontend/subject_screen.dart';
import 'package:classroom_frontend/payment_screen.dart';
import 'package:classroom_frontend/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String role; // 'teacher' | 'student' | 'admin'
  final String fullname; // passed from OTP verify
  final String mobile; // passed from OTP verify
  final String email;

  const DashboardScreen({
    super.key,
    required this.role,
    required this.fullname,
    required this.mobile,
    required this.email,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _TabDef {
  final String label;
  final IconData icon;
  final Widget screen;
  const _TabDef(this.label, this.icon, this.screen);
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _index = 0;

  // keep mutable copies so we can update after profile save
  late String _fullname;
  late String _email;

  @override
  void initState() {
    super.initState();
    _fullname = widget.fullname;
    _email = widget.email;
  }

  // Build tabs every build so they reflect latest _fullname/_email
  // List<_TabDef> _buildTabs() {
  //   final tabs = <_TabDef>[
  //     _TabDef('Classroom', Icons.school_rounded, const SubjectListScreen()),
  //   ];

  //   if (widget.role == 'student' || widget.role == 'admin') {
  //     tabs.add(
  //       _TabDef('Payments', Icons.payment_rounded, const PaymentScreen()),
  //     );
  //   }
  //   if (widget.role == 'admin') {
  //     tabs.add(
  //       _TabDef('Reports', Icons.bar_chart_rounded, const ReportsScreen()),
  //     );
  //   }

  //   tabs.add(
  //     _TabDef(
  //       'Profile',
  //       Icons.person_rounded,
  //       ProfileScreen(
  //         fullname: _fullname,
  //         mobile: widget.mobile,
  //         role: widget.role,
  //         email: _email,
  //         onUpdated: (newFullname, newEmail) {
  //           // <-- gets called after successful save
  //           setState(() {
  //             _fullname = newFullname;
  //             _email = newEmail;
  //           });
  //         },
  //       ),
  //     ),
  //   );
  //   return tabs;
  // }

  List<_TabDef> _buildTabs() {
    final tabs = <_TabDef>[];

    // ✅ Classroom tab passes the correct role + teacherMobile
    if (widget.role == 'admin') {
      tabs.add(
        _TabDef(
          'Classroom',
          Icons.school_rounded,
          const AdminClassroomScreen(),
        ),
      );
    } else if (widget.role == 'teacher') {
      tabs.add(
        _TabDef(
          'Classroom',
          Icons.school_rounded,
          SubjectListScreen(
            role: 'teacher',
            teacherMobile: widget.mobile, // required for teacher API
          ),
        ),
      );
    } else {
      tabs.add(
        _TabDef(
          'Classroom',
          Icons.school_rounded,
          SubjectListScreen(role: 'student', teacherMobile: widget.mobile),
        ),
      );
    }

    // if (widget.role == 'student' || widget.role == 'admin') {
    //   tabs.add(
    //     _TabDef(
    //       'Payments',
    //       Icons.payment_rounded,
    //       PaymentScreen(mobile: widget.mobile, email: _email),
    //     ),
    //   );
    // }

    // Payments tab (student/admin only)
    // if (widget.role == 'admin') {
    //   tabs.add(
    //     _TabDef('Payments', Icons.payment_rounded, const AdminPaymentsScreen()),
    //   );
    // } else
    if (widget.role == 'student') {
      tabs.add(
        _TabDef(
          'Payments',
          Icons.payment_rounded,
          PaymentScreen(mobile: widget.mobile, email: _email),
        ),
      );
    }
    if (widget.role == 'admin') {
      tabs.add(
        _TabDef('Reports', Icons.bar_chart_rounded, const AdminReportsScreen()),
      );
      tabs.add(
        _TabDef(
          'Subject',
          Icons.bar_chart_rounded,
          const AdminSubjectsScreen(),
        ),
      );
      tabs.add(_TabDef('Users', Icons.group, const AdminUsersScreen()));
    }

    tabs.add(
      _TabDef(
        'Profile',
        Icons.person_rounded,
        ProfileScreen(
          fullname: _fullname,
          mobile: widget.mobile,
          role: widget.role,
          email: _email,
          onUpdated: (newFullname, newEmail) {
            setState(() {
              _fullname = newFullname;
              _email = newEmail;
            });
          },
        ),
      ),
    );

    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _buildTabs();
    return Scaffold(
      body: tabs[_index].screen,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF13A0A4),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: [
          for (final t in tabs)
            BottomNavigationBarItem(
              icon: Icon(t.icon, color: Colors.black),
              label: t.label,
            ),
        ],
      ),
    );
  }
}

/// Simple placeholder—replace with your real Reports UI later.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Reports (Admin)', style: TextStyle(fontSize: 18)),
    );
  }
}

// class _DashboardScreenState extends State<DashboardScreen> {
//   late final List<_TabDef> _tabs;
//   int _index = 0;

//   @override
//   void initState() {
//     super.initState();
//     _tabs = _buildTabs(widget.role);
//   }

//   List<_TabDef> _buildTabs(String role) {
//     final tabs = <_TabDef>[
//       _TabDef('Classroom', Icons.school_rounded, const SubjectListScreen()),
//     ];

//     if (role == 'student' || role == 'admin') {
//       tabs.add(
//         _TabDef('Payments', Icons.payment_rounded, const PaymentScreen()),
//       );
//     }

//     if (role == 'admin') {
//       tabs.add(
//         _TabDef('Reports', Icons.bar_chart_rounded, const ReportsScreen()),
//       );
//     }

//     tabs.add(
//       _TabDef(
//         'Profile',
//         Icons.person_rounded,
//         ProfileScreen(
//           fullname: widget.fullname,
//           mobile: widget.mobile,
//           role: widget.role,
//           email: widget.email,
//         ),
//       ),
//     );
//     return tabs;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final roleTitle = widget.role.isEmpty ? '' : ' (${widget.role})';
//     return Scaffold(
//       // appBar: AppBar(
//       //   centerTitle: true,
//       //   title: Text('Dashboard$roleTitle'),
//       //   backgroundColor: Colors.teal,
//       // ),
//       body: _tabs[_index].screen,
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Color(0xFF13A0A4),
//         selectedItemColor: Colors.black,
//         unselectedItemColor: Colors.black,
//         currentIndex: _index,
//         type: BottomNavigationBarType.fixed,
//         onTap: (i) => setState(() => _index = i),
//         items: [
//           for (final t in _tabs)
//             BottomNavigationBarItem(
//               icon: Icon(t.icon, color: Colors.black),
//               label: t.label,
//             ),
//         ],
//       ),
//     );
//   }
// }
