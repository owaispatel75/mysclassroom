// import 'dart:async';
// import 'package:classroom_frontend/app_user.dart';
// import 'package:flutter/material.dart';
// import 'package:classroom_frontend/api_service.dart';

// class AdminUsersScreen extends StatefulWidget {
//   const AdminUsersScreen({super.key});

//   @override
//   State<AdminUsersScreen> createState() => _AdminUsersScreenState();
// }

// class _AdminUsersScreenState extends State<AdminUsersScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tab;
//   String _search = '';
//   Timer? _debounce;

//   @override
//   void initState() {
//     super.initState();
//     _tab = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _tab.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged(String v) {
//     _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 350), () {
//       setState(() => _search = v.trim());
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final role = _tab.index == 0 ? 'student' : 'teacher';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admin • Users'),
//         backgroundColor: const Color(0xFF13A0A4),
//         bottom: TabBar(
//           controller: _tab,
//           tabs: const [
//             Tab(text: 'Students'),
//             Tab(text: 'Teachers'),
//           ],
//           onTap: (_) => setState(() {}),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: const Color(0xFFEE4C82),
//         onPressed: () => _openUserDialog(role: role),
//         child: const Icon(Icons.add),
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
//             const SizedBox(height: 12),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: TextField(
//                 decoration: const InputDecoration(
//                   filled: true,
//                   fillColor: Colors.white,
//                   prefixIcon: Icon(Icons.search),
//                   hintText: 'Search by name / mobile / email',
//                   border: OutlineInputBorder(),
//                 ),
//                 onChanged: _onSearchChanged,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Expanded(
//               child: _UsersList(
//                 role: role,
//                 search: _search,
//                 onEdit: _openUserDialog,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _openUserDialog({AppUser? user, required String role}) async {
//     final fullnameCtl = TextEditingController(text: user?.fullname ?? '');
//     final mobileCtl = TextEditingController(text: user?.mobile ?? '');
//     final emailCtl = TextEditingController(text: user?.email ?? '');
//     String roleSel = user?.role ?? role; // default tab's role
//     bool active = user?.active ?? true;

//     final isEdit = user != null;

//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(
//           isEdit
//               // ? 'Edit ${user!.fullname}'
//               ? 'Edit ${user.fullname}'
//               : 'Add ${roleSel[0].toUpperCase()}${roleSel.substring(1)}',
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(
//                 controller: fullnameCtl,
//                 decoration: const InputDecoration(labelText: 'Full name'),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: mobileCtl,
//                 decoration: const InputDecoration(labelText: 'Mobile *'),
//                 keyboardType: TextInputType.phone,
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: emailCtl,
//                 decoration: const InputDecoration(labelText: 'Email'),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 8),
//               DropdownButtonFormField<String>(
//                 value: roleSel,
//                 decoration: const InputDecoration(labelText: 'Role *'),
//                 items: const [
//                   DropdownMenuItem(value: 'student', child: Text('Student')),
//                   DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
//                 ],
//                 onChanged: (v) => roleSel = v ?? roleSel,
//               ),
//               const SizedBox(height: 8),
//               SwitchListTile(
//                 title: const Text('Active'),
//                 value: active,
//                 onChanged: (v) => setState(() => active = v),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           if (isEdit)
//             TextButton(
//               onPressed: () async {
//                 // Delete (soft) user
//                 try {
//                   // await ApiService.adminDeleteUser(user!.id);
//                   await ApiService.adminDeleteUser(user.id);
//                   if (mounted) Navigator.pop(context);
//                 } catch (e) {
//                   if (!mounted) return;
//                   ScaffoldMessenger.of(
//                     context,
//                   ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
//                 }
//               },
//               style: TextButton.styleFrom(foregroundColor: Colors.red),
//               child: const Text('Delete'),
//             ),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           FilledButton(
//             onPressed: () async {
//               try {
//                 if (isEdit) {
//                   await ApiService.adminUpdateUser(
//                     // id: user!.id,
//                     id: user.id,
//                     fullname: fullnameCtl.text.trim().isEmpty
//                         ? null
//                         : fullnameCtl.text.trim(),
//                     mobile: mobileCtl.text.trim().isEmpty
//                         ? null
//                         : mobileCtl.text.trim(),
//                     email: emailCtl.text.trim().isEmpty
//                         ? null
//                         : emailCtl.text.trim(),
//                     role: roleSel,
//                     active: active,
//                   );
//                 } else {
//                   await ApiService.adminCreateUser(
//                     fullname: fullnameCtl.text.trim().isEmpty
//                         ? null
//                         : fullnameCtl.text.trim(),
//                     mobile: mobileCtl.text.trim(),
//                     email: emailCtl.text.trim().isEmpty
//                         ? null
//                         : emailCtl.text.trim(),
//                     role: roleSel,
//                     active: active,
//                   );
//                 }
//                 if (mounted) Navigator.pop(context);
//                 // Trigger list refresh by rebuilding
//                 setState(() {});
//               } catch (e) {
//                 if (!mounted) return;
//                 ScaffoldMessenger.of(
//                   context,
//                 ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
//               }
//             },
//             child: Text(isEdit ? 'Save' : 'Create'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _UsersList extends StatefulWidget {
//   final String role;
//   final String search;
//   final Future<void> Function({AppUser? user, required String role}) onEdit;

//   const _UsersList({
//     required this.role,
//     required this.search,
//     required this.onEdit,
//   });

//   @override
//   State<_UsersList> createState() => _UsersListState();
// }

// class _UsersListState extends State<_UsersList> {
//   late Future<Map<String, dynamic>> _future;

//   @override
//   void didUpdateWidget(covariant _UsersList oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.role != widget.role || oldWidget.search != widget.search) {
//       _future = _load();
//       setState(() {});
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _future = _load();
//   }

//   Future<Map<String, dynamic>> _load() {
//     return ApiService.adminFetchUsers(
//       role: widget.role,
//       search: widget.search.isEmpty ? null : widget.search,
//       page: 1,
//       perPage: 200,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _future,
//       builder: (_, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snap.hasError) {
//           return Center(
//             child: Text(
//               'Error: ${snap.error}',
//               style: const TextStyle(color: Colors.white),
//             ),
//           );
//         }
//         final map = snap.data ?? const {};
//         final list = (map['users'] as List? ?? []).cast<dynamic>();
//         if (list.isEmpty) {
//           return const Center(
//             child: Text(
//               'No users found',
//               style: TextStyle(color: Colors.white),
//             ),
//           );
//         }
//         final users = list
//             .map((e) => AppUser.fromJson(Map<String, dynamic>.from(e)))
//             .toList();

//         return ListView.builder(
//           padding: const EdgeInsets.all(12),
//           itemCount: users.length,
//           itemBuilder: (_, i) {
//             final u = users[i];
//             return Card(
//               color: Colors.white.withOpacity(0.95),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   child: Text(
//                     u.fullname.isNotEmpty
//                         ? u.fullname[0].toUpperCase()
//                         : u.role[0].toUpperCase(),
//                   ),
//                 ),
//                 title: Text(u.fullname.isEmpty ? '(No name)' : u.fullname),
//                 subtitle: Text(
//                   '${u.role.toUpperCase()} • ${u.mobile}${u.email.isNotEmpty ? ' • ${u.email}' : ''}',
//                 ),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (!u.active)
//                       const Padding(
//                         padding: EdgeInsets.only(right: 8.0),
//                         child: Icon(Icons.block, color: Colors.red),
//                       ),
//                     IconButton(
//                       icon: const Icon(Icons.edit),
//                       onPressed: () => widget.onEdit(user: u, role: u.role),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

import 'dart:async';
import 'package:classroom_frontend/app_user.dart';
import 'package:flutter/material.dart';
import 'package:classroom_frontend/api_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _search = '';
  Timer? _debounce;

  // NEW: a simple counter we bump whenever we need to force a refresh
  int _reloadTick = 0;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tab.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() => _search = v.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = _tab.index == 0 ? 'student' : 'teacher';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin • Users'),
        backgroundColor: const Color(0xFF13A0A4),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Students'),
            Tab(text: 'Teachers'),
          ],
          onTap: (_) => setState(() {}), // switch role
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEE4C82),
        onPressed: () => _openUserDialog(role: role),
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF13A0A4), Color(0xFF3CCACA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search by name / mobile / email',
                  border: OutlineInputBorder(),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _UsersList(
                role: role,
                search: _search,
                reloadToken: _reloadTick, // <- drives refresh
                onEdit: _openUserDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUserDialog({AppUser? user, required String role}) async {
    final fullnameCtl = TextEditingController(text: user?.fullname ?? '');
    final mobileCtl = TextEditingController(text: user?.mobile ?? '');
    final emailCtl = TextEditingController(text: user?.email ?? '');
    String roleSel = user?.role ?? role; // default tab's role
    bool active = user?.active ?? true;

    final isEdit = user != null;

    // NOTE: we await a bool from the dialog; true means "data changed"
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(
            isEdit
                ? 'Edit ${user!.fullname}'
                : 'Add ${roleSel[0].toUpperCase()}${roleSel.substring(1)}',
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: fullnameCtl,
                  decoration: const InputDecoration(labelText: 'Full name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: mobileCtl,
                  decoration: const InputDecoration(labelText: 'Mobile *'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: roleSel,
                  decoration: const InputDecoration(labelText: 'Role *'),
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text('Student')),
                    DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                  ],
                  onChanged: (v) => setLocal(() => roleSel = v ?? roleSel),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Active'),
                  value: active,
                  onChanged: (v) => setLocal(() => active = v),
                ),
              ],
            ),
          ),
          actions: [
            if (isEdit)
              TextButton(
                onPressed: () async {
                  try {
                    await ApiService.adminDeleteUser(user!.id);
                    if (context.mounted)
                      Navigator.pop(context, true); // changed
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Delete failed: $e')),
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context, false), // not changed
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  if (isEdit) {
                    await ApiService.adminUpdateUser(
                      id: user!.id,
                      fullname: fullnameCtl.text.trim().isEmpty
                          ? null
                          : fullnameCtl.text.trim(),
                      mobile: mobileCtl.text.trim().isEmpty
                          ? null
                          : mobileCtl.text.trim(),
                      email: emailCtl.text.trim().isEmpty
                          ? null
                          : emailCtl.text.trim(),
                      role: roleSel,
                      active: active,
                    );
                  } else {
                    await ApiService.adminCreateUser(
                      fullname: fullnameCtl.text.trim().isEmpty
                          ? null
                          : fullnameCtl.text.trim(),
                      mobile: mobileCtl.text.trim(),
                      email: emailCtl.text.trim().isEmpty
                          ? null
                          : emailCtl.text.trim(),
                      role: roleSel,
                      active: active,
                    );
                  }
                  if (context.mounted) Navigator.pop(context, true); // changed
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
                }
              },
              child: Text(isEdit ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );

    // If dialog says "changed", bump reload token to force list refetch
    if (changed == true && mounted) {
      setState(() => _reloadTick++);
    }
  }
}

class _UsersList extends StatefulWidget {
  final String role;
  final String search;
  final int reloadToken; // NEW: bump to force reload
  final Future<void> Function({AppUser? user, required String role}) onEdit;

  const _UsersList({
    required this.role,
    required this.search,
    required this.reloadToken,
    required this.onEdit,
  });

  @override
  State<_UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<_UsersList> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant _UsersList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role ||
        oldWidget.search != widget.search ||
        oldWidget.reloadToken != widget.reloadToken) {
      // any of these changes should re-fetch
      _future = _load();
      setState(() {});
    }
  }

  Future<Map<String, dynamic>> _load() {
    return ApiService.adminFetchUsers(
      role: widget.role,
      search: widget.search.isEmpty ? null : widget.search,
      page: 1,
      perPage: 200,
    );
  }

  Future<void> _pullToRefresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _pullToRefresh,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Text(
                    'Error: ${snap.error}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          }
          final map = snap.data ?? const {};
          final list = (map['users'] as List? ?? []).cast<dynamic>();
          if (list.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                Center(
                  child: Text(
                    'No users found',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          }
          final users = list
              .map((e) => AppUser.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (_, i) {
              final u = users[i];
              return Card(
                color: Colors.white.withOpacity(0.95),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      u.fullname.isNotEmpty
                          ? u.fullname[0].toUpperCase()
                          : u.role[0].toUpperCase(),
                    ),
                  ),
                  title: Text(u.fullname.isEmpty ? '(No name)' : u.fullname),
                  subtitle: Text(
                    '${u.role.toUpperCase()} • ${u.mobile}'
                    '${u.email.isNotEmpty ? ' • ${u.email}' : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!u.active)
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.block, color: Colors.red),
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => widget.onEdit(user: u, role: u.role),
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
