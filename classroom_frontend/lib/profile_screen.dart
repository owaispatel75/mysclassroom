//working starts
// import 'package:flutter/material.dart';
// // import 'package:online_classes/core/constants/app_colors.dart';
// // import 'package:online_classes/core/constants/app_sizedboxes.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: AppColors.bgColor,
//       backgroundColor: Colors.teal[300],
//       appBar: AppBar(
//         backgroundColor: Colors.teal,
//         title: const Text(
//           'Profile',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Profile Image
//             Center(
//               child: Stack(
//                 children: [
//                   const CircleAvatar(
//                     radius: 60,
//                     backgroundImage: AssetImage(''),
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: CircleAvatar(
//                       radius: 18,
//                       backgroundColor: Colors.white,
//                       child: Icon(Icons.edit, color: Colors.teal, size: 18),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // AppSizedBoxes.height20,
//             SizedBox(height: 15),

//             // Name
//             _buildProfileField(icon: Icons.person, label: "Name", value: ""),
//             // AppSizedBoxes.height15,
//             SizedBox(height: 15),
//             // Password
//             _buildProfileField(
//               icon: Icons.lock,
//               label: "Password",
//               value: "",
//               isPassword: true,
//             ),
//             SizedBox(height: 15),

//             // Mail
//             _buildProfileField(icon: Icons.email, label: "Mail", value: ""),
//             // AppSizedBoxes.height15,
//             SizedBox(height: 15),
//             // Phone Number
//             _buildProfileField(
//               icon: Icons.phone,
//               label: "Phone Number",
//               value: "",
//             ),
//             // AppSizedBoxes.height20,
//             SizedBox(height: 15),

//             // Submit Button
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.teal,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () {
//                   // Handle form submission here
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Profile Submitted")),
//                   );
//                 },
//                 child: const Text(
//                   "Submit",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Custom Profile Field Widget
//   Widget _buildProfileField({
//     required IconData icon,
//     required String label,
//     required String value,
//     bool isPassword = false,
//   }) {
//     return TextFormField(
//       initialValue: value,
//       obscureText: isPassword,
//       decoration: InputDecoration(
//         prefixIcon: Icon(icon, color: Colors.teal),
//         // prefixIcon: Icon(icon, color: AppColors.app_bar_color),
//         labelText: label,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         filled: true,
//         fillColor: Colors.white,
//       ),
//     );
//   }
// }
//working ends

import 'package:flutter/material.dart';
import 'package:classroom_frontend/api_service.dart';
import 'package:classroom_frontend/device_id.dart';
import 'package:classroom_frontend/Login_Screen.dart';

class ProfileScreen extends StatefulWidget {
  // pass these from the verify-otp response (or load from storage)
  final String fullname;
  final String mobile;
  final String role;
  final String email;
  final void Function(String newFullname, String newEmail)? onUpdated;

  const ProfileScreen({
    super.key,
    required this.fullname,
    required this.mobile,
    required this.role,
    required this.email,
    this.onUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.fullname);
    _emailCtrl = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // Future<void> _save() async {
  //   if (!_formKey.currentState!.validate()) return;
  //   setState(() => _saving = true);
  //   try {
  //     await ApiService.updateProfile(
  //       mobile: widget.mobile, // server uses this to find user
  //       fullname: _nameCtrl.text.trim(),
  //       email: _emailCtrl.text.trim(),
  //     );
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Profile updated')));
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
  //   } finally {
  //     if (mounted) setState(() => _saving = false);
  //   }
  // }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ApiService.updateProfile(
        mobile: widget.mobile,
        fullname: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );
      // inform parent so Dashboard rebuilds with latest values
      widget.onUpdated?.call(_nameCtrl.text.trim(), _emailCtrl.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logoutThisDevice() async {
    final deviceId = await getDeviceId();
    try {
      await ApiService.logout(widget.mobile, deviceId);
    } finally {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  Future<void> _logoutAll() async {
    try {
      await ApiService.logoutAll(widget.mobile);
    } finally {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[300],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar (static for now)
              CircleAvatar(radius: 48, backgroundColor: Colors.white70),
              const SizedBox(height: 16),

              _ProfileField(
                icon: Icons.person,
                label: 'Name',
                controller: _nameCtrl,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
              ),
              const SizedBox(height: 12),

              _ProfileField(
                icon: Icons.email,
                label: 'Email',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final x = (v ?? '').trim();
                  if (x.isEmpty) return null; // optional
                  final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(x);
                  return ok ? null : 'Enter a valid email';
                },
              ),
              const SizedBox(height: 12),

              // 🔒 Mobile is read-only
              _ReadOnlyField(
                icon: Icons.phone,
                label: 'Mobile',
                value: widget.mobile,
              ),
              const SizedBox(height: 12),

              _ReadOnlyField(
                icon: Icons.verified_user,
                label: 'Role',
                value: widget.role,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      onPressed: _logoutThisDevice,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Logout all devices'),
                      onPressed: _logoutAll,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ProfileField({
    required this.icon,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ReadOnlyField({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal),
        // labelText: label,
        hint: Text(label),
        filled: true,
        fillColor: Colors.white70,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
