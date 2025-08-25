import 'dart:async';

// import 'package:classroom_frontend/SubjectListScreen.dart';
import 'package:classroom_frontend/api_service.dart';
import 'package:classroom_frontend/dashboard_Screen.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:another_flushbar/flushbar.dart'; // Make sure this import points to your SubjectListScreen

class otpScreen extends StatefulWidget {
  final String mobile;
  final String deviceId;
  const otpScreen({super.key, required this.mobile, required this.deviceId});

  @override
  State<otpScreen> createState() => _otpScreenState();
}

class _otpScreenState extends State<otpScreen> {
  final TextEditingController _pinController = TextEditingController();
  Timer? _timer;
  bool _shown = false; // prevent duplicate banners
  bool _disposed = false;

  @override
  void initState() {
    super.initState();

    // 1) Fetch immediately
    _tryFetchOtp(showIfFound: true);
    // 2) Then poll quickly until we get it
    _timer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      _tryFetchOtp(showIfFound: true);
    });

    // // poll every 2s for OTP and show as local notification
    // _timer = Timer.periodic(const Duration(seconds: 2), (t) async {
    //   final otp = await ApiService.fetchOtp(widget.mobile);
    //   if (otp != null && otp.isNotEmpty) {
    //     print(otp);
    //     //await Notifier.showOtp(otp);
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       Flushbar(
    //         title: "Mobile Verified Successfully",
    //         message: "Your otp number is $otp",
    //         duration: Duration(seconds: 3),
    //         flushbarPosition: FlushbarPosition.TOP,
    //         // backgroundColor: Colors.grey.shade400,
    //         backgroundColor: Colors.white,
    //         margin: EdgeInsets.all(10),
    //         borderRadius: BorderRadius.circular(8),
    //         //icon: Icon(Icons.check_circle, color: Colors.black),
    //         titleColor: Colors.black,
    //         messageColor: Colors.black,
    //       ).show(context);
    //     });
    //     t.cancel(); // stop polling after first OTP
    //   }
    // });
  }

  Future<void> _tryFetchOtp({bool showIfFound = false}) async {
    if (_shown || _disposed) return;
    try {
      final otp = await ApiService.fetchOtp(widget.mobile);
      if (!_disposed && otp != null && otp.isNotEmpty) {
        if (showIfFound && !_shown) {
          _shown = true;
          _timer?.cancel();
          // Show banner immediately
          Flushbar(
            title: "Mobile Verified Successfully",
            message: "Your OTP number is $otp",
            duration: const Duration(seconds: 3),
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: Colors.white,
            margin: const EdgeInsets.all(10),
            borderRadius: BorderRadius.circular(8),
            titleColor: Colors.black,
            messageColor: Colors.black,
          ).show(context);

          // Optional: auto-fill the input
          _pinController.text = otp;
        }
      }
    } catch (_) {
      // ignore transient errors; next poll will try again
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  // Future<void> _verify() async {
  //   final otp = _pinController.text.trim();
  //   if (otp.isEmpty) return;
  //   try {
  //     final user = await ApiService.verifyOtp(widget.mobile, otp);
  //     final role = (user['role'] ?? '').toString();
  //     if (!mounted) return;
  //     if (role == 'teacher') {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => const SubjectListScreenTeacher()),
  //       );
  //     } else {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => const SubjectListScreenStudent()),
  //       );
  //     }
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Verification failed: $e')));
  //   }
  // }

  Future<void> _verify() async {
    final otp = _pinController.text.trim();
    if (otp.isEmpty) return;
    try {
      final user = await ApiService.verifyOtp(
        widget.mobile,
        otp,
        widget.deviceId,
      );
      final role = (user['role'] ?? '').toString();
      final fullname = (user['fullname'] ?? '').toString();
      final mobile = (user['mobile'] ?? widget.mobile).toString();
      final email = (user['email'] ?? '').toString();
      // Navigator.pushReplacement(
      //   context,
      //   // MaterialPageRoute(builder: (_) => DashboardScreen(role: role)),
      //   MaterialPageRoute(builder: (_) => DashboardScreen(role: role)),
      // );

      print(email);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
            role: role,
            fullname: fullname,
            mobile: mobile,
            email: email,
          ),
          // DashboardScreen(role: role), // pass role if needed
        ),
        (Route<dynamic> route) => false, // remove all previous routes
      );
    } catch (e) {
      if (e.toString().contains('ALREADY_LOGGED')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account active on another device.')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Verification failed: $e')));
      }
    }
  }

  // @override
  // void dispose() {
  //   _timer?.cancel();
  //   _pinController.dispose();
  //   super.dispose();
  // }

  // Future<void> _verify() async {
  //   final otp = _pinController.text.trim();
  //   if (otp.isEmpty) return;
  //   try {
  //     final user = await ApiService.verifyOtp(widget.mobile, otp);
  //     final role = (user['role'] ?? '').toString();
  //     if (role == 'teacher') {
  //       Navigator.pushReplacement(
  //         context,
  //         //MaterialPageRoute(builder: (_) => const SubjectListScreen()),
  //         MaterialPageRoute(builder: (_) => const SubjectListScreenTeacher()),
  //       );
  //     } else {
  //       Navigator.pushReplacement(
  //         context,
  //         //MaterialPageRoute(builder: (_) => const SubjectListScreen()),
  //         MaterialPageRoute(builder: (_) => const SubjectListScreenStudent()),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Verification failed: $e')));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00BABA),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Color(0xFF13A0A4),
        centerTitle: true,
        title: Text('Enter OTP', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Enter OTP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Pinput(
                  mainAxisAlignment: MainAxisAlignment.center,
                  length: 4,
                  controller: _pinController,
                  pinAnimationType: PinAnimationType.fade,
                  onCompleted: (pin) {
                    print("Pin entered: $pin");
                  },
                  onChanged: (pin) {
                    print("Pin is: $pin");
                  },
                  defaultPinTheme: PinTheme(
                    width: 70,
                    height: 50,
                    textStyle: TextStyle(
                      color: Color(0xff323232),
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: TextStyle(
                      color: Color(0xff323232),
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 241, 217, 226),
                      border: Border.all(color: Colors.pink),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: 70,
                    height: 50,
                    textStyle: TextStyle(
                      color: Color(0xff323232),
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 241, 217, 226),
                      border: Border.all(color: Colors.pink),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  // onPressed: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => SubjectListScreen(),
                  //     ),
                  //   );
                  // },
                  onPressed: _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEE4C82),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class myContainer extends StatefulWidget {
  final Widget child;
  const myContainer({super.key, required this.child});

  @override
  State<myContainer> createState() => _myContainerState();
}

class _myContainerState extends State<myContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: widget.child,
    );
  }
}
