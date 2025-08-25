// import 'package:classroom_frontend/payment_screen.dart';
// import 'package:classroom_frontend/profile_screen.dart';
// import 'package:flutter/material.dart';
// // import 'package:online_classes/features/dashboard/presentation/page3.dart';
// // import 'package:online_classes/features/payment/presentation/payment_screen.dart';

// class SubjectListScreen extends StatefulWidget {
//   const SubjectListScreen({super.key});

//   @override
//   State<SubjectListScreen> createState() => _SubjectListScreenState();
// }

// class _SubjectListScreenState extends State<SubjectListScreen> {
//   final List<String> subjects = [
//     'English',
//     'Hindi',
//     'Marathi',
//     'Science',
//     'Maths',
//     // 'Profile',
//     // 'Payment' // ✅ Added Payment card
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Subject List',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: const Color(0xFF13A0A4),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF13A0A4), Color(0xFF3CCACA)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Column(
//           children: [
//             Expanded(
//               child: Scrollbar(
//                 thickness: 6,
//                 radius: const Radius.circular(10),
//                 thumbVisibility: true,
//                 child: ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   physics: const BouncingScrollPhysics(),
//                   itemCount: subjects.length,
//                   itemBuilder: (context, index) {
//                     return Card(
//                       elevation: 6,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       margin: const EdgeInsets.symmetric(vertical: 10),
//                       color: Colors.white.withOpacity(0.85),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: ListTile(
//                           leading: const Icon(Icons.book, color: Colors.pink),
//                           title: Text(
//                             subjects[index],
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.deepPurple,
//                             ),
//                           ),
//                           trailing: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFFEE4C82),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             onPressed: () {
//                               // if (subjects[index] == 'Profile') {
//                               //   // Navigator.push(
//                               //   //   context,
//                               //   //   MaterialPageRoute(
//                               //   //       builder: (_) => const ProfileScreen()),
//                               //   // );
//                               // } else if (subjects[index] == 'Payment') {
//                               //   Navigator.push(
//                               //     context,
//                               //     MaterialPageRoute(
//                               //       builder: (_) => const PaymentScreen(),
//                               //     ),
//                               //   );
//                               // } else {
//                               //   ScaffoldMessenger.of(context).showSnackBar(
//                               //     SnackBar(
//                               //       content: Text(
//                               //         'Starting ${subjects[index]}...',
//                               //       ),
//                               //       duration: const Duration(seconds: 1),
//                               //     ),
//                               //   );
//                               // }
//                             },
//                             child: Text(
//                               subjects[index] == 'Profile'
//                                   ? "View"
//                                   : subjects[index] == 'Payment'
//                                   ? "Pay"
//                                   : "Start",
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//student working starts

// import 'package:classroom_frontend/TodaySession_model.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:classroom_frontend/api_service.dart';

// class SubjectListScreen extends StatefulWidget {
//   const SubjectListScreen({super.key});

//   @override
//   State<SubjectListScreen> createState() => _SubjectListScreenState();
// }

// class _SubjectListScreenState extends State<SubjectListScreen> {
//   late Future<List<TodaySession>> _future;

//   @override
//   void initState() {
//     super.initState();
//     _future = ApiService.fetchTodaySessions(); // optionally pass classroomId
//   }

//   String _timeRange(TodaySession s) {
//     final f = DateFormat('h:mm a');
//     return '${f.format(s.startAt)} – ${f.format(s.endAt)}';
//   }

//   Color _chipColor(String status) {
//     switch (status) {
//       case 'live':
//         return Colors.green;
//       case 'scheduled':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Today\'s Classes',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: const Color(0xFF13A0A4),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF13A0A4), Color(0xFF3CCACA)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: FutureBuilder<List<TodaySession>>(
//           future: _future,
//           builder: (context, snap) {
//             if (snap.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (snap.hasError) {
//               return Center(
//                 child: Text(
//                   'Error: ${snap.error}',
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               );
//             }
//             final sessions = snap.data ?? const [];
//             if (sessions.isEmpty) {
//               return const Center(
//                 child: Text(
//                   'No classes left today',
//                   style: TextStyle(color: Colors.black, fontSize: 16),
//                 ),
//               );
//             }
//             return ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: sessions.length,
//               itemBuilder: (context, i) {
//                 final s = sessions[i];
//                 return Card(
//                   elevation: 6,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   margin: const EdgeInsets.symmetric(vertical: 10),
//                   color: Colors.white.withOpacity(0.9),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 10,
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.book, color: Colors.pink),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 s.subject,
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.deepPurple,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 _timeRange(s),
//                                 style: const TextStyle(color: Colors.black87),
//                               ),
//                               const SizedBox(height: 6),
//                               Chip(
//                                 label: Text(
//                                   s.status.toUpperCase(),
//                                   style: const TextStyle(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 backgroundColor: _chipColor(s.status),
//                                 visualDensity: VisualDensity.compact,
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: s.joinable
//                                 ? const Color(0xFFEE4C82)
//                                 : Colors.grey,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           onPressed: s.joinable
//                               ? () {
//                                   // TODO: integrate Zego join here later
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text('Joining ${s.subject}...'),
//                                     ),
//                                   );
//                                 }
//                               : null,
//                           child: Text(
//                             s.joinable ? 'Join' : 'Yet to start',
//                             style: const TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

//student working ends

//it is working fine but due to zegocloud starts
// import 'dart:async';

// import 'package:classroom_frontend/TodaySession_model.dart';
// import 'package:classroom_frontend/api_service.dart';
// import 'package:classroom_frontend/live_pages.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// /// role: 'student' | 'teacher' | 'admin' (admin can behave like teacher or student later)
// /// teacherMobile: required when role == 'teacher'
// class SubjectListScreen extends StatefulWidget {
//   final String role;
//   final String teacherMobile;

//   const SubjectListScreen({
//     super.key,
//     this.role = 'student',
//     required this.teacherMobile,
//   });

//   @override
//   State<SubjectListScreen> createState() => _SubjectListScreenState();
// }

// class _SubjectListScreenState extends State<SubjectListScreen> {
//   late Future<List<TodaySession>> _future;
//   Timer? _autoRefresh;
//   final _timeFmt = DateFormat('h:mm a');

//   @override
//   void initState() {
//     super.initState();
//     _future = _load();
//     // Optional: light auto-refresh so teacher/student views stay fresh.
//     _autoRefresh = Timer.periodic(const Duration(seconds: 30), (_) {
//       if (!mounted) return;
//       // final fut = _load();
//       // setState(() {
//       //   _future = fut;
//       // });
//       final next = _load();
//       setState(() {
//         _future = next;
//       });
//       // setState(() => _future = _load());
//     });
//   }

//   @override
//   void dispose() {
//     _autoRefresh?.cancel();
//     super.dispose();
//   }

//   Future<List<TodaySession>> _load() {
//     if (widget.role == 'teacher') {
//       final mobile = widget.teacherMobile;
//       return ApiService.fetchTeacherToday(teacherMobile: mobile);
//     }
//     // default: student view
//     // return ApiService.fetchTodaySessions();
//     // final studentmobile = widget.teacherMobile;
//     return ApiService.fetchTodaySessionsForStudent(widget.teacherMobile);
//   }

//   String _timeRange(TodaySession s) =>
//       '${_timeFmt.format(s.startAt)} – ${_timeFmt.format(s.endAt)}';

//   Color _chipColor(String status) {
//     switch (status) {
//       case 'live':
//         return Colors.green;
//       case 'scheduled':
//         return Colors.orange;
//       case 'ended':
//         return Colors.grey;
//       default:
//         return Colors.blueGrey;
//     }
//   }

//   Future<void> _startClass(int id) async {
//     try {
//       await ApiService.startClass(id); // 1) await async work
//       final next = _load(); // 2) prepare new future
//       if (!mounted) return;
//       setState(() {
//         _future = next;
//       }); // 3) update synchronously
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Class started')));
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Start failed: $e')));
//     }
//   }

//   Future<void> _endClass(int id) async {
//     try {
//       await ApiService.endClass(id); // 1) await async work
//       final next = _load(); // 2) prepare new future
//       if (!mounted) return;
//       setState(() {
//         _future = next;
//       }); // 3) update synchronously
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Class ended')));
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('End failed: $e')));
//     }
//   }

//   // Future<void> _startClass(int id) async {
//   //   try {
//   //     await ApiService.startClass(id);
//   //     if (!mounted) return;
//   //     ScaffoldMessenger.of(
//   //       context,
//   //     ).showSnackBar(const SnackBar(content: Text('Class started')));
//   //     setState(() => _future = _load());
//   //   } catch (e) {
//   //     if (!mounted) return;
//   //     ScaffoldMessenger.of(
//   //       context,
//   //     ).showSnackBar(SnackBar(content: Text('Start failed: $e')));
//   //   }
//   // }

//   // Future<void> _endClass(int id) async {
//   //   try {
//   //     await ApiService.endClass(id);
//   //     if (!mounted) return;
//   //     ScaffoldMessenger.of(
//   //       context,
//   //     ).showSnackBar(const SnackBar(content: Text('Class ended')));
//   //     setState(() => _future = _load());
//   //   } catch (e) {
//   //     if (!mounted) return;
//   //     ScaffoldMessenger.of(
//   //       context,
//   //     ).showSnackBar(SnackBar(content: Text('End failed: $e')));
//   //   }
//   // }

//   // Widget _actionButtonForStudent(TodaySession s) {
//   //   final enabled = s.joinable;
//   //   return ElevatedButton(
//   //     style: ElevatedButton.styleFrom(
//   //       backgroundColor: enabled ? const Color(0xFFEE4C82) : Colors.grey,
//   //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//   //     ),
//   //     onPressed: enabled
//   //         ? () async {
//   //             try {
//   //               await ApiService.markAttendance(
//   //                 sessionId: s.id,
//   //                 mobile: widget.teacherMobile,
//   //               );
//   //               // before opening the live/player page
//   //               await ApiService.attendanceStart(
//   //                 sessionId: s.id,
//   //                 mobile: widget.teacherMobile,
//   //               );
//   //               // push a placeholder "InClassScreen"
//   //               Navigator.push(
//   //                 context,
//   //                 MaterialPageRoute(
//   //                   builder: (_) => InClassScreen(
//   //                     sessionId: s.id,
//   //                     mobile: widget.teacherMobile,
//   //                     subject: s.subject,
//   //                   ),
//   //                 ),
//   //               );
//   //             } catch (_) {}
//   //             // then proceed to join video (later)
//   //             ScaffoldMessenger.of(context).showSnackBar(
//   //               SnackBar(content: Text('Joining ${s.subject}...')),
//   //             );
//   //           }
//   //         : null,

//   //     // onPressed: enabled
//   //     //     ? () {
//   //     //         // TODO: plug Zego join here
//   //     //         ScaffoldMessenger.of(context).showSnackBar(
//   //     //           SnackBar(content: Text('Joining ${s.subject}...')),
//   //     //         );
//   //     //       }
//   //     //     : null,
//   //     child: Text(
//   //       enabled ? 'Join' : 'Yet to start',
//   //       style: const TextStyle(
//   //         color: Colors.black,
//   //         fontWeight: FontWeight.w500,
//   //       ),
//   //     ),
//   //   );
//   // }

//   // Widget _actionButtonForTeacher(TodaySession s) {
//   //   final isLive = s.status == 'live';
//   //   if (!isLive) {
//   //     return ElevatedButton(
//   //       style: ElevatedButton.styleFrom(
//   //         backgroundColor: Colors.green,
//   //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//   //       ),
//   //       onPressed: () => _startClass(s.id),
//   //       child: const Text('Start', style: TextStyle(color: Colors.white)),
//   //     );
//   //   }
//   //   return ElevatedButton(
//   //     style: ElevatedButton.styleFrom(
//   //       backgroundColor: Colors.red,
//   //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//   //     ),
//   //     onPressed: () => _endClass(s.id),
//   //     child: const Text('End', style: TextStyle(color: Colors.white)),
//   //   );
//   // }

//   Widget _actionButtonForStudent(TodaySession s) {
//     final enabled = s.joinable;
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: enabled ? const Color(0xFFEE4C82) : Colors.grey,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//       onPressed: !enabled
//           ? null
//           : () async {
//               final liveID = 'class_${s.id}'; // MUST match teacher’s liveID
//               try {
//                 // optional: hit your attendance start
//                 await ApiService.attendanceStart(
//                   sessionId: s.id,
//                   mobile: widget
//                       .teacherMobile, // here this is actually the STUDENT mobile in your app
//                 );
//               } catch (_) {}

//               if (!mounted) return;
//               // open the live as audience (listen-only)
//               await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => LivePage(
//                     liveID: liveID,
//                     userID: widget
//                         .teacherMobile, // unique per student, you’re using mobile
//                     userName: 'Student', // or the real name if you have it
//                     isHost: false,
//                   ),
//                 ),
//               );

//               // when student leaves the room, stop attendance
//               try {
//                 await ApiService.attendanceStop(
//                   sessionId: s.id,
//                   mobile: widget.teacherMobile,
//                 );
//               } catch (_) {}

//               if (!mounted) return;
//               ScaffoldMessenger.of(
//                 context,
//               ).showSnackBar(SnackBar(content: Text('Left ${s.subject}')));
//             },
//       child: Text(
//         enabled ? 'Join' : 'Yet to start',
//         style: const TextStyle(
//           color: Colors.black,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   Widget _actionButtonForTeacher(TodaySession s) {
//     final isLive = s.status == 'live';

//     if (!isLive) {
//       return ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.green,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//         onPressed: () async {
//           // 1) set status live on backend
//           await _startClass(s.id);

//           if (!mounted) return;

//           // 2) immediately open the live as host/broadcaster
//           final liveID = 'class_${s.id}';
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => LivePage(
//                 liveID: liveID,
//                 userID: widget
//                     .teacherMobile, // teacher’s unique id (your app uses mobile)
//                 userName: 'Teacher',
//                 isHost: true,
//               ),
//             ),
//           );

//           // (optional) when teacher returns from live without pressing End in UI,
//           // you could decide to auto-end here. Most prefer a manual End button.
//         },
//         child: const Text('Start', style: TextStyle(color: Colors.white)),
//       );
//     }

//     // When live, keep simple "End" action (you can also add a separate "Open" if you want)
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.red,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//       onPressed: () async {
//         await _endClass(s.id);
//         if (!mounted) return;
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Class ended')));
//       },
//       child: const Text('End', style: TextStyle(color: Colors.white)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isTeacher = widget.role == 'teacher';

//     return Scaffold(
//       appBar: AppBar(
//         // title: Text(
//         //   isTeacher
//         //       ? "Today's Classes (Teacher)"
//         //       : "Today's Classes ${widget.role}",
//         //   style: const TextStyle(fontWeight: FontWeight.bold),
//         // ),
//         title: Text(
//           "Today's Classes ${widget.role}",
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: const Color(0xFF13A0A4),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF13A0A4), Color(0xFF3CCACA)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: RefreshIndicator(
//           // onRefresh: () async {
//           //   final fut = _load();
//           //   setState(() {
//           //     _future = fut;
//           //   });
//           // },
//           onRefresh: () async {
//             final next = _load(); // kick off new load
//             setState(() {
//               _future = next;
//             });
//             await next; // return a Future so the spinner knows when to stop
//           },
//           // onRefresh: () async => setState(() => _future = _load()),
//           child: FutureBuilder<List<TodaySession>>(
//             future: _future,
//             builder: (context, snap) {
//               if (snap.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (snap.hasError) {
//                 return ListView(
//                   children: [
//                     const SizedBox(height: 200),
//                     Center(
//                       child: Text(
//                         'Error: ${snap.error}',
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 );
//               }
//               final sessions = snap.data ?? const [];
//               if (sessions.isEmpty) {
//                 return ListView(
//                   children: const [
//                     SizedBox(height: 200),
//                     Center(
//                       child: Text(
//                         'No classes left today',
//                         style: TextStyle(color: Colors.black, fontSize: 16),
//                       ),
//                     ),
//                   ],
//                 );
//               }
//               return ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: sessions.length,
//                 itemBuilder: (context, i) {
//                   final s = sessions[i];
//                   return Card(
//                     elevation: 6,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     margin: const EdgeInsets.symmetric(vertical: 10),
//                     color: Colors.white.withOpacity(0.9),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 10,
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.book, color: Colors.pink),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   s.subject,
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.deepPurple,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   _timeRange(s),
//                                   style: const TextStyle(color: Colors.black87),
//                                 ),
//                                 const SizedBox(height: 6),
//                                 Chip(
//                                   label: Text(
//                                     s.status.toUpperCase(),
//                                     style: const TextStyle(
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   backgroundColor: _chipColor(s.status),
//                                   visualDensity: VisualDensity.compact,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           // Action per role
//                           isTeacher
//                               ? _actionButtonForTeacher(s)
//                               : _actionButtonForStudent(s),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:classroom_frontend/TodaySession_model.dart';
import 'package:classroom_frontend/api_service.dart';
import 'package:classroom_frontend/live_pages.dart';
import 'package:classroom_frontend/offering_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// role: 'student' | 'teacher' | 'admin'
/// teacherMobile is used ONLY when role == 'teacher'
class SubjectListScreen extends StatefulWidget {
  final String role;

  /// Kept for backward-compat: used when role == 'teacher'
  final String teacherMobile;

  /// NEW: pass the logged-in student's mobile (used for attendance etc.)
  final String? studentMobile;

  /// NEW: when provided (and role != teacher), we fetch the teacher’s classes
  /// and filter by this subject for TODAY.
  final Offering? offeringFilter;

  const SubjectListScreen({
    super.key,
    this.role = 'student',
    required this.teacherMobile,
    this.studentMobile,
    this.offeringFilter,
  });

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  late Future<List<TodaySession>> _future;
  Timer? _autoRefresh;
  final _timeFmt = DateFormat('h:mm a');

  String get _studentMobile => widget.studentMobile ?? widget.teacherMobile;

  // @override
  // void initState() {
  //   super.initState();
  //   _future = _load();
  //   _autoRefresh = Timer.periodic(const Duration(seconds: 30), (_) {
  //     if (!mounted) return;
  //     final next = _load();
  //     setState(() => _future = next);
  //   });
  // }

  @override
  void initState() {
    super.initState();

    // Fail-fast during development if wiring is wrong
    assert(
      widget.role != 'teacher' || widget.teacherMobile.isNotEmpty,
      'Teacher view requires teacherMobile',
    );
    debugPrint(
      '[SubjectList] role=${widget.role} '
      'teacher=${widget.teacherMobile} student=$_studentMobile',
    );

    _future = _load();
    _autoRefresh = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() => _future = _load());
    });
  }

  @override
  void dispose() {
    _autoRefresh?.cancel();
    super.dispose();
  }

  // Future<List<TodaySession>> _load() {
  //   if (widget.role == 'teacher') {
  //     // teacher view: all today classes for this teacher
  //     return ApiService.fetchTeacherToday(teacherMobile: widget.teacherMobile);
  //   }

  //   // student view with subject filter: show teacher’s classes filtered by subject
  //   if (widget.offeringFilter != null) {
  //     final off = widget.offeringFilter!;
  //     return ApiService.fetchTeacherToday(
  //       teacherMobile: off.teacherMobile,
  //     ).then(
  //       (list) => list.where((s) => s.subject == off.subjectname).toList(),
  //     );
  //   }

  //   // default student view: all accessible classes for this student (today)
  //   return ApiService.fetchTodaySessionsForStudent(_studentMobile);
  // }

  // Future<List<TodaySession>> _load() {
  //   if (widget.role == 'teacher') {
  //     return ApiService.fetchTeacherToday(teacherMobile: widget.teacherMobile);
  //   }
  //   // Student only sees enrolled subjects' classes
  //   // return ApiService.fetchEnrolledSessionsForStudent(widget.teacherMobile);
  //   return ApiService.fetchTodaySessionsForStudent(widget.teacherMobile);
  // }

  // Future<List<TodaySession>> _load() {
  //   if (widget.role == 'teacher') {
  //     return ApiService.fetchTeacherToday(teacherMobile: widget.teacherMobile);
  //   }
  //   return ApiService.fetchTodaySessionsForStudent(_studentMobile);
  // }

  // Future<List<TodaySession>> _load() {
  //   if (widget.role == 'teacher') {
  //     final me = ApiService.normalizeMobile(widget.teacherMobile);
  //     return ApiService.fetchTodayAll().then((all) {
  //       return all.where((s) {
  //         final tm = s.teacherMobile ?? '';
  //         return ApiService.normalizeMobile(tm) == me;
  //       }).toList();
  //     });
  //   }
  //   // student path unchanged
  //   return ApiService.fetchTodaySessionsForStudent(_studentMobile);
  // }

  Future<List<TodaySession>> _load() {
    final day = DateTime.now(); // show "this day" only
    if (widget.role == 'teacher') {
      return ApiService.fetchTeacherOnDay(
        teacherMobile: widget.teacherMobile,
        day: day,
      );
    }
    return ApiService.fetchTodaySessionsForStudentOnDay(
      _studentMobile,
      day: day,
    );
  }

  String _timeRange(TodaySession s) =>
      '${_timeFmt.format(s.startAt)} – ${_timeFmt.format(s.endAt)}';

  Color _chipColor(String status) {
    switch (status) {
      case 'live':
        return Colors.green;
      case 'scheduled':
        return Colors.orange;
      case 'ended':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> _startClass(int id) async {
    try {
      await ApiService.startClass(id);
      final next = _load();
      if (!mounted) return;
      setState(() => _future = next);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Class started')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Start failed: $e')));
    }
  }

  Future<void> _endClass(int id) async {
    try {
      await ApiService.endClass(id);
      final next = _load();
      if (!mounted) return;
      setState(() => _future = next);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Class ended')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('End failed: $e')));
    }
  }

  Widget _actionButtonForStudent(TodaySession s) {
    final enabled = s.joinable;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? const Color(0xFFEE4C82) : Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: !enabled
          ? null
          : () async {
              final liveID = 'class_${s.id}';
              try {
                await ApiService.attendanceStart(
                  sessionId: s.id,
                  mobile: _studentMobile,
                );
              } catch (_) {}

              if (!mounted) return;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LivePage(
                    liveID: liveID,
                    userID: _studentMobile,
                    userName: 'Student',
                    isHost: false,
                  ),
                ),
              );

              try {
                await ApiService.attendanceStop(
                  sessionId: s.id,
                  mobile: _studentMobile,
                );
              } catch (_) {}

              if (!mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Left ${s.subject}')));
            },
      child: Text(
        enabled ? 'Join' : 'Yet to start',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _actionButtonForTeacher(TodaySession s) {
    final isLive = s.status == 'live';
    if (!isLive) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () async {
          await _startClass(s.id);
          if (!mounted) return;
          final liveID = 'class_${s.id}';
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LivePage(
                liveID: liveID,
                userID: widget.teacherMobile,
                userName: 'Teacher',
                isHost: true,
              ),
            ),
          );
        },
        child: const Text('Start', style: TextStyle(color: Colors.white)),
      );
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () async {
        await _endClass(s.id);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Class ended')));
      },
      child: const Text('End', style: TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = widget.role == 'teacher';
    final titleSuffix = isTeacher
        ? "Teacher"
        : (widget.offeringFilter != null
              ? "${widget.offeringFilter!.subjectname}"
              : "Student");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Today's Classes • $titleSuffix",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF13A0A4),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF13A0A4), Color(0xFF3CCACA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            final next = _load();
            setState(() => _future = next);
            await next;
          },
          child: FutureBuilder<List<TodaySession>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return ListView(
                  children: [
                    const SizedBox(height: 200),
                    Center(
                      child: Text(
                        'Error: ${snap.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              }
              final sessions = snap.data ?? const [];
              if (sessions.isEmpty) {
                return ListView(
                  children: const [
                    SizedBox(height: 200),
                    Center(
                      child: Text(
                        'No classes left today',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ],
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sessions.length,
                itemBuilder: (context, i) {
                  final s = sessions[i];
                  return Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.book, color: Colors.pink),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.subject,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _timeRange(s),
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                const SizedBox(height: 6),
                                Chip(
                                  label: Text(
                                    s.status.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: _chipColor(s.status),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          isTeacher
                              ? _actionButtonForTeacher(s)
                              : _actionButtonForStudent(s),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
