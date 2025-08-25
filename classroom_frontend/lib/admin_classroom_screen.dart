// import 'package:classroom_frontend/TeacherUser_model.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:classroom_frontend/api_service.dart';
// import 'package:classroom_frontend/TodaySession_model.dart';

// class AdminClassroomScreen extends StatefulWidget {
//   const AdminClassroomScreen({super.key});

//   @override
//   State<AdminClassroomScreen> createState() => _AdminClassroomScreenState();
// }

// class _AdminClassroomScreenState extends State<AdminClassroomScreen> {
//   DateTime _day = DateTime.now();
//   late Future<List<TodaySession>> _future;
//   final _fmt = DateFormat('d MMM, h:mm a');

//   @override
//   void initState() {
//     super.initState();
//     _future = ApiService.adminFetchSubjects(_day);
//   }

//   // Future<void> _reload() async {
//   //   setState(() => _future = ApiService.adminFetchSubjects(_day));
//   // }

//   // after
//   Future<void> _reload() async {
//     final fut = ApiService.adminFetchSubjects(_day);
//     setState(() {
//       _future = fut; // <- block body returns void
//     });
//   }

//   // Future<void> _pickDay() async {
//   //   final picked = await showDatePicker(
//   //     context: context,
//   //     initialDate: _day,
//   //     firstDate: DateTime(2023),
//   //     lastDate: DateTime(2030),
//   //   );
//   //   if (picked != null) {
//   //     setState(() {
//   //       _day = picked;
//   //       _future = ApiService.adminFetchSubjects(_day);
//   //     });
//   //   }
//   // }

//   Future<void> _pickDay() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _day,
//       firstDate: DateTime(2023),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null) {
//       final fut = ApiService.adminFetchSubjects(picked);
//       setState(() {
//         _day = picked;
//         _future = fut;
//       });
//     }
//   }

//   Future<void> _openForm({TodaySession? existing}) async {
//     final result = await showModalBottomSheet<bool>(
//       context: context,
//       isScrollControlled: true,
//       builder: (_) => _SubjectForm(day: _day, existing: existing),
//     );
//     if (result == true) _reload();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manage Classes'),
//         centerTitle: true,
//         backgroundColor: const Color(0xFF13A0A4),
//         actions: [
//           IconButton(onPressed: _pickDay, icon: const Icon(Icons.event)),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: const Color(0xFF13A0A4),
//         onPressed: () => _openForm(),
//         child: const Icon(Icons.add),
//       ),
//       body: FutureBuilder<List<TodaySession>>(
//         future: _future,
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snap.hasError) {
//             return Center(child: Text('Error: ${snap.error}'));
//           }
//           final rows = snap.data ?? const [];
//           if (rows.isEmpty) {
//             return const Center(child: Text('No sessions for selected date'));
//           }
//           return ListView.builder(
//             itemCount: rows.length,
//             padding: const EdgeInsets.all(12),
//             itemBuilder: (_, i) {
//               final s = rows[i];
//               return Dismissible(
//                 key: ValueKey(s.id),
//                 direction: DismissDirection.endToStart,
//                 background: Container(
//                   alignment: Alignment.centerRight,
//                   padding: const EdgeInsets.only(right: 20),
//                   color: Colors.red,
//                   child: const Icon(Icons.delete, color: Colors.white),
//                 ),
//                 confirmDismiss: (_) async {
//                   final yes = await showDialog<bool>(
//                     context: context,
//                     builder: (_) => AlertDialog(
//                       title: const Text('Delete class?'),
//                       content: Text('Delete "${s.subject}"?'),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context, false),
//                           child: const Text('Cancel'),
//                         ),
//                         ElevatedButton(
//                           onPressed: () => Navigator.pop(context, true),
//                           child: const Text('Delete'),
//                         ),
//                       ],
//                     ),
//                   );
//                   if (yes == true) {
//                     await ApiService.adminDeleteSubject(s.id);
//                     await _reload();
//                   }
//                   return false;
//                 },
//                 child: Card(
//                   child: ListTile(
//                     title: Text(s.subject),
//                     subtitle: Text(
//                       '${_fmt.format(s.startAt)} • ${s.durationMins} mins • ${s.status}',
//                     ),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.edit),
//                       onPressed: () => _openForm(existing: s),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class _SubjectForm extends StatefulWidget {
//   final DateTime day;
//   final TodaySession? existing;

//   const _SubjectForm({required this.day, this.existing});

//   @override
//   State<_SubjectForm> createState() => _SubjectFormState();
// }

// class _SubjectFormState extends State<_SubjectForm> {
//   final _form = GlobalKey<FormState>();
//   final _subjectCtrl = TextEditingController();
//   //final _teacherMobileCtrl = TextEditingController();
//   final _classroomNameCtrl = TextEditingController();
//   final _durationCtrl = TextEditingController(text: '60');
//   DateTime _startAt = DateTime.now();
//   String _status = 'scheduled';

//   List<TeacherUser> _teachers = [];
//   String? _selectedTeacherMobile; // we keep the mobile; label shows name

//   @override
//   void initState() {
//     super.initState();
//     if (widget.existing != null) {
//       final e = widget.existing!;
//       _subjectCtrl.text = e.subject;
//       _durationCtrl.text = e.durationMins.toString();
//       _startAt = e.startAt;
//       _status = e.status;
//       _selectedTeacherMobile = e.teacherMobile; // may be null
//       // optional fields only if you store them in model
//       // _teacherMobileCtrl.text = e.teacherMobile ?? '';
//       // _classroomNameCtrl.text  = e.classroomName ?? '';
//     } else {
//       // align start date to selected day
//       _startAt = DateTime(
//         widget.day.year,
//         widget.day.month,
//         widget.day.day,
//         TimeOfDay.now().hour,
//         0,
//       );
//     }

//     // load teachers
//     ApiService.fetchTeachers()
//         .then((list) {
//           if (!mounted) return;
//           setState(() {
//             _teachers = list;
//             // if the preselected value is not present in the list, clear it
//             final exists = _teachers.any(
//               (t) => t.mobile == _selectedTeacherMobile,
//             );
//             if (!exists) _selectedTeacherMobile = null;
//           });
//         })
//         .catchError((_) {
//           if (!mounted) return;
//           setState(() => _teachers = []);
//         });
//     // // load teachers
//     // ApiService.fetchTeachers()
//     //     .then((list) {
//     //       if (!mounted) return;
//     //       setState(() => _teachers = list);
//     //     })
//     //     .catchError((e) {
//     //       // optional: show a toast/snack
//     //     });
//   }

//   @override
//   void dispose() {
//     _subjectCtrl.dispose();
//     //_teacherMobileCtrl.dispose();
//     _classroomNameCtrl.dispose();
//     _durationCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _pickDateTime() async {
//     final d = await showDatePicker(
//       context: context,
//       initialDate: _startAt,
//       firstDate: DateTime(2023),
//       lastDate: DateTime(2030),
//     );
//     if (d == null) return;
//     final t = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.fromDateTime(_startAt),
//     );
//     if (t == null) return;
//     setState(() {
//       _startAt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
//     });
//   }

//   // Future<void> _save() async {
//   //   if (!_form.currentState!.validate()) return;

//   //   final duration = int.parse(_durationCtrl.text);
//   //   if (widget.existing == null) {
//   //     await ApiService.adminCreateSubject(
//   //       classroomName: _classroomNameCtrl.text.isEmpty
//   //           ? null
//   //           : _classroomNameCtrl.text,
//   //       teacherMobile: _teacherMobileCtrl.text.isEmpty
//   //           ? null
//   //           : _teacherMobileCtrl.text,
//   //       subject: _subjectCtrl.text.trim(),
//   //       startAt: _startAt,
//   //       durationMins: duration,
//   //       status: _status,
//   //     );
//   //   } else {
//   //     await ApiService.adminUpdateSubject(
//   //       id: widget.existing!.id,
//   //       classroomName: _classroomNameCtrl.text.isEmpty
//   //           ? null
//   //           : _classroomNameCtrl.text,
//   //       teacherMobile: _teacherMobileCtrl.text.isEmpty
//   //           ? null
//   //           : _teacherMobileCtrl.text,
//   //       subject: _subjectCtrl.text.trim(),
//   //       startAt: _startAt,
//   //       durationMins: duration,
//   //       status: _status,
//   //     );
//   //   }
//   //   if (!mounted) return;
//   //   Navigator.pop(context, true);
//   // }

//   Future<void> _save() async {
//     if (!_form.currentState!.validate()) return;

//     final duration = int.parse(_durationCtrl.text);
//     try {
//       if (widget.existing == null) {
//         await ApiService.adminCreateSubject(
//           classroomName: _classroomNameCtrl.text.isEmpty
//               ? null
//               : _classroomNameCtrl.text,
//           teacherMobile: _selectedTeacherMobile, // <—
//           // teacherMobile: _teacherMobileCtrl.text.isEmpty
//           //     ? null
//           //     : _teacherMobileCtrl.text,
//           subject: _subjectCtrl.text.trim(),
//           startAt: _startAt,
//           durationMins: duration,
//           status: _status,
//         );
//       } else {
//         await ApiService.adminUpdateSubject(
//           id: widget.existing!.id,
//           classroomName: _classroomNameCtrl.text.isEmpty
//               ? null
//               : _classroomNameCtrl.text,
//           teacherMobile: _selectedTeacherMobile,
//           // teacherMobile: _teacherMobileCtrl.text.isEmpty
//           //     ? null
//           //     : _teacherMobileCtrl.text,
//           subject: _subjectCtrl.text.trim(),
//           startAt: _startAt,
//           durationMins: duration,
//           status: _status,
//         );
//       }
//       if (!mounted) return;
//       Navigator.pop(context, true);
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dropdownValue =
//         _teachers.any((t) => t.mobile == _selectedTeacherMobile)
//         ? _selectedTeacherMobile
//         : null;
//     final pad = MediaQuery.of(context).viewInsets.bottom;
//     return Padding(
//       padding: EdgeInsets.only(bottom: pad),
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Form(
//             key: _form,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   widget.existing == null ? 'Create class' : 'Edit class',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: _subjectCtrl,
//                   decoration: const InputDecoration(
//                     labelText: 'Subject name',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (v) =>
//                       (v == null || v.trim().isEmpty) ? 'Required' : null,
//                 ),
//                 const SizedBox(height: 12),

//                 // NEW: Teacher dropdown
//                 // DropdownButtonFormField<String?>(
//                 //   value: _selectedTeacherMobile,
//                 //   decoration: const InputDecoration(
//                 //     labelText: 'Teacher',
//                 //     border: OutlineInputBorder(),
//                 //   ),
//                 //   isExpanded: true,
//                 //   items: [
//                 //     const DropdownMenuItem<String?>(
//                 //       value: null,
//                 //       child: Text('— None —'),
//                 //     ),
//                 //     ..._teachers.map(
//                 //       (t) => DropdownMenuItem<String?>(
//                 //         value: t.mobile,
//                 //         child: Text(t.fullname),
//                 //       ),
//                 //     ),
//                 //   ],
//                 //   onChanged: (v) => setState(() => _selectedTeacherMobile = v),
//                 // ),
//                 DropdownButtonFormField<String?>(
//                   value: dropdownValue, // <- ONLY a value that exists, or null
//                   isExpanded: true,
//                   decoration: const InputDecoration(
//                     labelText: 'Teacher',
//                     border: OutlineInputBorder(),
//                   ),
//                   items: <DropdownMenuItem<String?>>[
//                     const DropdownMenuItem<String?>(
//                       value: null,
//                       child: Text('— None —'),
//                     ),
//                     ..._teachers.map(
//                       (t) => DropdownMenuItem<String?>(
//                         value: t.mobile, // store MOBILE
//                         child: Text(t.fullname), // show NAME
//                       ),
//                     ),
//                   ],
//                   onChanged: (v) => setState(() => _selectedTeacherMobile = v),
//                 ),

//                 // TextFormField(
//                 //   controller: _teacherMobileCtrl,
//                 //   decoration: const InputDecoration(
//                 //     labelText: 'Teacher mobile (optional)',
//                 //     border: OutlineInputBorder(),
//                 //   ),
//                 //   keyboardType: TextInputType.phone,
//                 // ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: _classroomNameCtrl,
//                   decoration: const InputDecoration(
//                     labelText: 'Classroom name (optional)',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: _durationCtrl,
//                   decoration: const InputDecoration(
//                     labelText: 'Duration (mins)',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (v) =>
//                       (int.tryParse(v ?? '') ?? 0) > 0 ? null : 'Enter minutes',
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         'Start:  ${DateFormat('d MMM, h:mm a').format(_startAt)}',
//                       ),
//                     ),
//                     TextButton.icon(
//                       onPressed: _pickDateTime,
//                       icon: const Icon(Icons.schedule),
//                       label: const Text('Pick'),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 DropdownButtonFormField<String>(
//                   value: _status,
//                   items: const [
//                     DropdownMenuItem(
//                       value: 'scheduled',
//                       child: Text('scheduled'),
//                     ),
//                     DropdownMenuItem(value: 'live', child: Text('live')),
//                     DropdownMenuItem(value: 'ended', child: Text('ended')),
//                   ],
//                   onChanged: (v) => setState(() => _status = v ?? 'scheduled'),
//                   decoration: const InputDecoration(
//                     labelText: 'Status',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _save,
//                     child: const Text('Save'),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_service.dart';
import '../TodaySession_model.dart';
import '../offering_model.dart';

class AdminClassroomScreen extends StatefulWidget {
  const AdminClassroomScreen({super.key});

  @override
  State<AdminClassroomScreen> createState() => _AdminClassroomScreenState();
}

class _AdminClassroomScreenState extends State<AdminClassroomScreen> {
  DateTime _day = DateTime.now();
  late Future<List<TodaySession>> _future;
  final _fmt = DateFormat('d MMM, h:mm a');

  @override
  void initState() {
    super.initState();
    _future = ApiService.adminFetchSubjects(_day);
  }

  // Future<void> _reload() async {
  //   setState(() => _future = ApiService.adminFetchSubjects(_day));
  // }

  Future<void> _reload() async {
    // kick off the future first
    final fut = ApiService.adminFetchSubjects(_day);
    // synchronously update the state with the new Future
    setState(() {
      _future = fut;
    });
    // (Optional) await it outside of setState if you need to block afterwards
    // await fut;
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;

    final fut = ApiService.adminFetchSubjects(picked);
    setState(() {
      _day = picked;
      _future = fut;
    });
    // await fut; // only if you need to do something after it completes
  }

  // Future<void> _pickDay() async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: _day,
  //     firstDate: DateTime(2023),
  //     lastDate: DateTime(2030),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       _day = picked;
  //       _future = ApiService.adminFetchSubjects(_day);
  //     });
  //   }
  // }

  Future<void> _openForm({TodaySession? existing}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SubjectForm(day: _day, existing: existing),
    );
    if (result == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Classes'),
        centerTitle: true,
        backgroundColor: const Color(0xFF13A0A4),
        actions: [
          IconButton(onPressed: _pickDay, icon: const Icon(Icons.event)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF13A0A4),
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<TodaySession>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final rows = snap.data ?? const [];
          if (rows.isEmpty) {
            return const Center(child: Text('No sessions for selected date'));
          }
          return ListView.builder(
            itemCount: rows.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (_, i) {
              final s = rows[i];
              return Dismissible(
                key: ValueKey(s.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  final yes = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete class?'),
                      content: Text('Delete "${s.subject}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (yes == true) {
                    await ApiService.adminDeleteSubject(s.id);
                    await _reload();
                  }
                  return false;
                },
                child: Card(
                  child: ListTile(
                    title: Text(s.subject),
                    subtitle: Text(
                      '${_fmt.format(s.startAt)} • ${s.durationMins} mins • ${s.status}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openForm(existing: s),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SubjectForm extends StatefulWidget {
  final DateTime day;
  final TodaySession? existing;

  const _SubjectForm({required this.day, this.existing});

  @override
  State<_SubjectForm> createState() => _SubjectFormState();
}

class _SubjectFormState extends State<_SubjectForm> {
  final _form = GlobalKey<FormState>();

  // Subject + Teacher (auto or custom)
  List<Offering> _offerings = [];
  Offering? _selectedOffering;

  final _subjectCtrl =
      TextEditingController(); // editable when no offering selected
  final _teacherCtrl =
      TextEditingController(); // editable when no offering selected

  // Other fields
  final _classroomNameCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '60');
  DateTime _startAt = DateTime.now();
  String _status = 'scheduled';

  @override
  void initState() {
    super.initState();

    if (widget.existing != null) {
      final e = widget.existing!;
      _subjectCtrl.text = e.subject;
      _teacherCtrl.text = e.teacherMobile ?? '';
      _durationCtrl.text = e.durationMins.toString();
      _startAt = e.startAt;
      _status = e.status;
    } else {
      _startAt = DateTime(
        widget.day.year,
        widget.day.month,
        widget.day.day,
        TimeOfDay.now().hour,
        0,
      );
    }

    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final items = await ApiService.fetchOfferings();
      Offering? match;
      if (widget.existing != null) {
        // match = items.firstWhere(
        //   (o) =>
        //       o.subjectname == _subjectCtrl.text.trim() &&
        //       o.teacherMobile == _teacherCtrl.text.trim(),
        //   orElse: () => items.isNotEmpty ?  Offering : null,
        // );

        Offering? match = items
            .where(
              (o) =>
                  o.subjectname == _subjectCtrl.text.trim() &&
                  o.teacherMobile == _teacherCtrl.text.trim(),
            )
            .cast<Offering?>()
            .firstOrNull;
      }
      setState(() {
        _offerings = items;
        _selectedOffering = match;
        if (_selectedOffering != null) {
          _subjectCtrl.text = _selectedOffering!.subjectname;
          _teacherCtrl.text = _selectedOffering!.teacherMobile;
        }
      });
    } catch (e) {
      // keep fields editable if offerings fail to load
    }
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _teacherCtrl.dispose();
    _classroomNameCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startAt,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (d == null) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startAt),
    );
    if (t == null) return;
    setState(
      () => _startAt = DateTime(d.year, d.month, d.day, t.hour, t.minute),
    );
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    final duration = int.parse(_durationCtrl.text);
    final subject = _selectedOffering?.subjectname ?? _subjectCtrl.text.trim();
    final teacherMobile =
        _selectedOffering?.teacherMobile ?? _teacherCtrl.text.trim();

    try {
      if (widget.existing == null) {
        await ApiService.adminCreateSubject(
          classroomName: _classroomNameCtrl.text.isEmpty
              ? null
              : _classroomNameCtrl.text,
          teacherMobile: teacherMobile.isEmpty ? null : teacherMobile,
          subject: subject,
          startAt: _startAt,
          durationMins: duration,
          status: _status,
        );
      } else {
        await ApiService.adminUpdateSubject(
          id: widget.existing!.id,
          classroomName: _classroomNameCtrl.text.isEmpty
              ? null
              : _classroomNameCtrl.text,
          teacherMobile: teacherMobile.isEmpty ? null : teacherMobile,
          subject: subject,
          startAt: _startAt,
          durationMins: duration,
          status: _status,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).viewInsets.bottom;

    // read-only iff an offering is selected
    final readOnly = _selectedOffering != null;

    return Padding(
      padding: EdgeInsets.only(bottom: pad),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.existing == null ? 'Create class' : 'Edit class',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // SUBJECT DROPDOWN (auto-fills teacher)
                DropdownButtonFormField<Offering?>(
                  value: _selectedOffering,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Subject (from subjects screen)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<Offering?>(
                      value: null,
                      child: Text('— Custom / Not listed —'),
                    ),
                    ..._offerings.map(
                      (o) => DropdownMenuItem<Offering?>(
                        value: o,
                        child: Text(o.displayLabel),
                      ),
                    ),
                  ],
                  onChanged: (o) {
                    setState(() {
                      _selectedOffering = o;
                      if (o != null) {
                        _subjectCtrl.text = o.subjectname;
                        _teacherCtrl.text = o.teacherMobile;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _subjectCtrl,
                  readOnly: readOnly,
                  decoration: const InputDecoration(
                    labelText: 'Subject name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _teacherCtrl,
                  readOnly: readOnly,
                  decoration: const InputDecoration(
                    labelText: 'Teacher mobile (auto from subject)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _classroomNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Classroom name (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _durationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Duration (mins)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (int.tryParse(v ?? '') ?? 0) > 0 ? null : 'Enter minutes',
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Start:  ${DateFormat('d MMM, h:mm a').format(_startAt)}',
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _pickDateTime,
                      icon: const Icon(Icons.schedule),
                      label: const Text('Pick'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(
                      value: 'scheduled',
                      child: Text('scheduled'),
                    ),
                    DropdownMenuItem(value: 'live', child: Text('live')),
                    DropdownMenuItem(value: 'ended', child: Text('ended')),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? 'scheduled'),
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
