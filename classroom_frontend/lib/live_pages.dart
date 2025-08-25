import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

/// ====== DEV ONLY! Replace with your real values ======
const int zegoAppID = 1957543287; // e.g. 123456789
const String zegoAppSign =
    'e7431c54561290acb4f06b41f347c8bc489a32ec28a60f525dbd949f453f24a1'; // long string

class LivePage extends StatelessWidget {
  final String liveID; // e.g. "maths_20250819_1100"
  final String userID; // unique per user (use mobile or DB id)
  final String userName; // display name
  final bool isHost; // teacher=true, student=false

  const LivePage({
    super.key,
    required this.liveID,
    required this.userID,
    required this.userName,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context) {
    // Choose config by role
    final config = isHost
        ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
        : ZegoUIKitPrebuiltLiveStreamingConfig.audience();

    // Optional: make sure only host publishes AV; audience is listen-only by default
    config.turnOnCameraWhenJoining = isHost;
    config.turnOnMicrophoneWhenJoining = isHost;

    // Keep everything else default; DO NOT set non-existing fields like
    // enableCoHosting or coHostEnabled.

    if (kIsWeb) {
      return const Center(
        child: Text(
          'Live streaming is available on Android/iOS app builds. '
          'For web, use the Web SDK.',
        ),
      );
    }

    return SafeArea(
      child: ZegoUIKitPrebuiltLiveStreaming(
        appID: zegoAppID,
        appSign: zegoAppSign,
        userID: userID,
        userName: userName,
        liveID: liveID,
        config: config,
      ),
    );
  }
}

/// We’ll use a deterministic room ID based on session id.
/// Both teacher and students must compute the same roomID.
// String roomIdForSession(int sessionId) => 'class_$sessionId';

// /// Teacher host page: one-way broadcast
// class TeacherLivePage extends StatelessWidget {
//   final String roomID;
//   final String userID;
//   final String userName;

//   const TeacherLivePage({
//     super.key,
//     required this.roomID,
//     required this.userID,
//     required this.userName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final config = ZegoUIKitPrebuiltLiveStreamingConfig.host()
//       // keep it "one-way": audience cannot co-host
//       ..enableCoHosting = false
//       ..turnOnCameraWhenJoining = true
//       ..turnOnMicrophoneWhenJoining = true;

//     return SafeArea(
//       child: ZegoUIKitPrebuiltLiveStreaming(
//         appID: zegoAppID,
//         appSign: zegoAppSign, // dev/demo only
//         userID: userID, // unique per user (use mobile)
//         userName: userName,
//         liveID: roomID, // <-- the shared room id
//         config: config,
//       ),
//     );
//   }
// }

// /// Student viewer page: audience/watch only
// class StudentLivePage extends StatelessWidget {
//   final String roomID;
//   final String userID;
//   final String userName;

//   const StudentLivePage({
//     super.key,
//     required this.roomID,
//     required this.userID,
//     required this.userName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final config = ZegoUIKitPrebuiltLiveStreamingConfig.audience()
//       // just watch; no co-host request
//       ..enableCoHosting = false;

//     return SafeArea(
//       child: ZegoUIKitPrebuiltLiveStreaming(
//         appID: zegoAppID,
//         appSign: zegoAppSign, // dev/demo only
//         userID: userID,
//         userName: userName,
//         liveID: roomID,
//         config: config,
//       ),
//     );
//   }
// }
// String roomIdForSession(int sessionId) => 'class_$sessionId';

// class TeacherLivePage extends StatelessWidget {
//   final String roomID, userID, userName;
//   const TeacherLivePage({
//     super.key,
//     required this.roomID,
//     required this.userID,
//     required this.userName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final config =
//         ZegoUIKitPrebuiltLiveStreamingConfig.host(
//             coHostEnabled: false, // disable co-hosting requests
//           )
//           ..turnOnCameraWhenJoining = true
//           ..turnOnMicrophoneWhenJoining = true;

//     return SafeArea(
//       child: ZegoUIKitPrebuiltLiveStreaming(
//         appID: zegoAppID,
//         appSign: zegoAppSign,
//         userID: userID,
//         userName: userName,
//         liveID: roomID,
//         config: config,
//       ),
//     );
//   }
// }

// class StudentLivePage extends StatelessWidget {
//   final String roomID, userID, userName;
//   const StudentLivePage({
//     super.key,
//     required this.roomID,
//     required this.userID,
//     required this.userName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final config = ZegoUIKitPrebuiltLiveStreamingConfig.audience(
//       coHostEnabled: false, // also disable co-hosting
//     );

//     return SafeArea(
//       child: ZegoUIKitPrebuiltLiveStreaming(
//         appID: zegoAppID,
//         appSign: zegoAppSign,
//         userID: userID,
//         userName: userName,
//         liveID: roomID,
//         config: config,
//       ),
//     );
//   }
// }
