// import 'package:classroom_frontend/api_service.dart';
// import 'package:classroom_frontend/otpscreen.dart';
// import 'package:flutter/material.dart';

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final phoneController = TextEditingController();
//     final passwordController = TextEditingController();

//     return Scaffold(
//       backgroundColor: const Color(0xFF3CCACA),
//       resizeToAvoidBottomInset: true, // important for keyboard adjustment
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: const Color(
//           0xFF13A0A4,
//         ), // optional: match app bar background too
//         elevation: 0, // optional: remove app bar shadow
//         title: const Text('Login'),
//         automaticallyImplyLeading: false, // removes the back button
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.only(
//           left: 20,
//           right: 20,
//           bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//           top: 20,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(child: Image.asset('assets/welcome.png', height: 250)),
//             const SizedBox(height: 20),
//             const Text(
//               "Mobile Number",
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               maxLength: 10,
//               // controller: phoneController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(10)),
//                 ),
//                 hintText: "Enter your number",
//               ),
//             ),
//             const SizedBox(height: 20),
//             Container(
//               width: double.infinity,
//               height: 50,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 color: const Color(
//                   0xFFEE4C82,
//                 ), // Teal background  borderRadius: BorderRadius.circular(19),
//               ),
//               child: Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(8),
//                   // onTap: () {
//                   //   Navigator.pushAndRemoveUntil(
//                   //     context,
//                   //     MaterialPageRoute(builder: (_) => const otpScreen()),
//                   //     (route) => false, // removes all previous routes
//                   //   );
//                   // },
//                   onTap: () async {
//                     final mobile = phoneController.text.trim();
//                     if (mobile.length != 10) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Enter 10-digit mobile')),
//                       );
//                       return;
//                     }
//                     try {
//                       await ApiService.sendOtp(mobile);
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => otpScreen(mobile: mobile),
//                         ),
//                       );
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Failed to send OTP: $e')),
//                       );
//                     }
//                   },
//                   child: const Center(
//                     child: Text(
//                       "Login",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:classroom_frontend/device_id.dart';
import 'package:flutter/material.dart';
import 'api_service.dart'; // your API calls
import 'otpscreen.dart'; // OtpScreen(mobile: ...)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final mobile = _phoneCtrl.text.trim();

    final deviceId = await getDeviceId();
    try {
      await ApiService.sendOtp(mobile, deviceId);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => otpScreen(mobile: mobile, deviceId: deviceId),
        ),
      );
    } catch (e) {
      if (e.toString().contains('ALREADY_LOGGED')) {
        final yes = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Already logged in'),
            content: const Text(
              'This account is active on another device. Logout from all devices?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout all'),
              ),
            ],
          ),
        );
        if (yes == true) {
          await ApiService.logoutAll(mobile);
          await ApiService.sendOtp(mobile, deviceId); // retry
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => otpScreen(mobile: mobile, deviceId: deviceId),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
    

    // try {
    //   setState(() => _loading = true);
    //   await ApiService.sendOtp(mobile, deviceId); // hits /send-otp
    //   if (!mounted) return;
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (_) => otpScreen(mobile: mobile)),
    //   );
    // } catch (e) {
    //   if (!mounted) return;
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('Failed to send OTP: $e')));
    // } finally {
    //   if (mounted) setState(() => _loading = false);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3CCACA),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF13A0A4),
        elevation: 0,
        title: const Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            const Text(
              "Mobile Number",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneCtrl, // ✅ now wired
              maxLength: 10,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                counterText: "", // hide 10/10 if you want
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                hintText: "Enter your number",
              ),
              validator: (v) {
                final m = (v ?? '').trim();
                // Basic 10-digit check (India-style starts 6-9); relax if needed
                final ok = RegExp(r'^[6-9]\d{9}$').hasMatch(m);
                return ok ? null : 'Enter 10-digit mobile';
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE4C82),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
