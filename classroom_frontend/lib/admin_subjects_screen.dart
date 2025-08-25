// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'api_service.dart';
// import 'offering_model.dart';

// class AdminSubjectsScreen extends StatefulWidget {
//   const AdminSubjectsScreen({super.key});

//   @override
//   State<AdminSubjectsScreen> createState() => _AdminSubjectsScreenState();
// }

// class _AdminSubjectsScreenState extends State<AdminSubjectsScreen> {

//   List<Offering> _offerings = [];
//   Offering? _selectedOffering;

//   final _subjectCtl = TextEditingController(); // will be auto-filled/read-only
//   final _teacherCtl = TextEditingController(); // auto-filled/read-only
//   final _classroomNameCtl = TextEditingController();
//   final _durationCtl = TextEditingController(text: '60');

//   bool _loadingOfferings = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadOfferings();
//   }

//   Future<void> _loadOfferings() async {
//     try {
//       final items = await ApiService.fetchOfferings();
//       setState(() {
//         _offerings = items;
//         _selectedOffering = items.isNotEmpty ? items.first : null;
//         _applyOfferingToFields();
//         _loadingOfferings = false;
//       });
//     } catch (e) {
//       setState(() => _loadingOfferings = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to load subjects: $e')));
//     }
//   }

//   void _applyOfferingToFields() {
//     if (_selectedOffering == null) {
//       _subjectCtl.text = '';
//       _teacherCtl.text = '';
//       return;
//     }
//     _subjectCtl.text = _selectedOffering!.subjectname;
//     _teacherCtl.text = _selectedOffering!.teacherMobile;
//   }

//   late Future<List<Offering>> _future;

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   _future = ApiService.fetchAllSubjects();
//   // }

//   void _reload() => setState(() => _future = ApiService.fetchAllSubjects());

//   Future<void> _showCreateDialog() async {
//     final subjectCtl = TextEditingController();
//     final teacherCtl = TextEditingController();
//     final priceCtl = TextEditingController(); // rupees (UI), convert to paise

//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Create Subject'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: subjectCtl,
//               decoration: const InputDecoration(
//                 labelText: 'Subject name (e.g., Maths)',
//               ),
//             ),
//             TextField(
//               controller: teacherCtl,
//               decoration: const InputDecoration(labelText: "Teacher's mobile"),
//             ),
//             TextField(
//               controller: priceCtl,
//               decoration: const InputDecoration(labelText: 'Per lecture (₹)'),
//               keyboardType: TextInputType.number,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );

//     if (ok != true) return;

//     final rupees = int.tryParse(priceCtl.text.trim()) ?? 0;
//     await ApiService.createSubject(
//       subjectname: subjectCtl.text.trim(),
//       teacherMobile: teacherCtl.text.trim(),
//       pricePaise: rupees * 100,
//     );
//     _reload();
//   }

//   Future<void> _showEditDialog(Offering o) async {
//     final subjectCtl = TextEditingController(text: o.subjectname);
//     final teacherCtl = TextEditingController(text: o.teacherMobile);
//     final priceCtl = TextEditingController(
//       text: (o.pricePaise / 100).toStringAsFixed(0),
//     );

//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Edit Subject'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: subjectCtl,
//               decoration: const InputDecoration(labelText: 'Subject name'),
//             ),
//             TextField(
//               controller: teacherCtl,
//               decoration: const InputDecoration(labelText: "Teacher's mobile"),
//             ),
//             TextField(
//               controller: priceCtl,
//               decoration: const InputDecoration(labelText: 'Per lecture (₹)'),
//               keyboardType: TextInputType.number,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Update'),
//           ),
//         ],
//       ),
//     );
//     if (ok != true) return;

//     await ApiService.updateSubject(
//       id: o.id,
//       subjectname: subjectCtl.text.trim(),
//       teacherMobile: teacherCtl.text.trim(),
//       pricePaise: (int.tryParse(priceCtl.text.trim()) ?? 0) * 100,
//     );
//     _reload();
//   }

//   @override
//   Widget build(BuildContext context) {
//     String money(int p) => '₹ ${(p / 100).toStringAsFixed(0)}';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Subjects (Admin)'),
//         backgroundColor: const Color(0xFF13A0A4),
//         actions: [
//           IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateDialog,
//         child: const Icon(Icons.add),
//       ),
//       body: FutureBuilder<List<Offering>>(
//         future: _future,
//         builder: (_, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snap.hasError) {
//             return Center(child: Text('Error: ${snap.error}'));
//           }
//           final items = snap.data ?? [];
//           if (items.isEmpty) {
//             return const Center(child: Text('No subjects yet. Tap + to add.'));
//           }
//           return ListView.builder(
//             itemCount: items.length,
//             itemBuilder: (_, i) {
//               final o = items[i];
//               return Card(
//                 child: ListTile(
//                   leading: const Icon(Icons.book),
//                   title: Text(o.subjectname),
//                   subtitle: Text(
//                     'Teacher: ${o.teacherMobile} • Rate: ${money(o.pricePaise)}',
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.edit),
//                         onPressed: () => _showEditDialog(o),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete),
//                         onPressed: () async {
//                           final yes = await showDialog<bool>(
//                             context: context,
//                             builder: (_) => AlertDialog(
//                               title: const Text('Delete?'),
//                               content: Text(
//                                 'Delete ${o.subjectname} (${o.teacherMobile})',
//                               ),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () =>
//                                       Navigator.pop(context, false),
//                                   child: const Text('Cancel'),
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () => Navigator.pop(context, true),
//                                   child: const Text('Delete'),
//                                 ),
//                               ],
//                             ),
//                           );
//                           if (yes == true) {
//                             await ApiService.deleteSubject(o.id);
//                             _reload();
//                           }
//                         },
//                       ),
//                     ],
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // (not used but you had it; safe to keep/remove)
import '../api_service.dart';
import '../offering_model.dart';

class AdminSubjectsScreen extends StatefulWidget {
  const AdminSubjectsScreen({super.key});

  @override
  State<AdminSubjectsScreen> createState() => _AdminSubjectsScreenState();
}

class _AdminSubjectsScreenState extends State<AdminSubjectsScreen> {
  late Future<List<Offering>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.fetchAllSubjects();
  }

  void _reload() => setState(() => _future = ApiService.fetchAllSubjects());

  Future<void> _showCreateDialog() async {
    final subjectCtl = TextEditingController();
    final teacherCtl = TextEditingController();
    final priceCtl = TextEditingController(); // rupees

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectCtl,
              decoration: const InputDecoration(labelText: 'Subject name'),
            ),
            TextField(
              controller: teacherCtl,
              decoration: const InputDecoration(labelText: "Teacher's mobile"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: priceCtl,
              decoration: const InputDecoration(labelText: 'Per lecture (₹)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final rupees = int.tryParse(priceCtl.text.trim()) ?? 0;
    await ApiService.createSubject(
      subjectname: subjectCtl.text.trim(),
      teacherMobile: teacherCtl.text.trim(),
      pricePaise: rupees * 100,
    );
    _reload();
  }

  Future<void> _showEditDialog(Offering o) async {
    final subjectCtl = TextEditingController(text: o.subjectname);
    final teacherCtl = TextEditingController(text: o.teacherMobile);
    final priceCtl = TextEditingController(
      text: (o.pricePaise / 100).toStringAsFixed(0),
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectCtl,
              decoration: const InputDecoration(labelText: 'Subject name'),
            ),
            TextField(
              controller: teacherCtl,
              decoration: const InputDecoration(labelText: "Teacher's mobile"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: priceCtl,
              decoration: const InputDecoration(labelText: 'Per lecture (₹)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await ApiService.updateSubject(
      id: o.id,
      subjectname: subjectCtl.text.trim(),
      teacherMobile: teacherCtl.text.trim(),
      pricePaise: (int.tryParse(priceCtl.text.trim()) ?? 0) * 100,
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    String money(int p) => '₹ ${(p / 100).toStringAsFixed(0)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects (Admin)'),
        backgroundColor: const Color(0xFF13A0A4),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Offering>>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No subjects yet. Tap + to add.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final o = items[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(o.subjectname),
                  subtitle: Text(
                    'Teacher: ${o.teacherMobile} • Rate: ${money(o.pricePaise)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(o),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final yes = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete?'),
                              content: Text(
                                'Delete ${o.subjectname} (${o.teacherMobile})',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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
                            await ApiService.deleteSubject(o.id);
                            _reload();
                          }
                        },
                      ),
                    ],
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
