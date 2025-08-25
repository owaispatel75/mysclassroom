// // Compiled for iOS/Android; does nothing
// void openRazorpay(
//   Map<String, dynamic> options, {
//   void Function(Map<String, dynamic> resp)? onSuccess,
//   void Function(Object err)? onError,
// }) {
//   throw UnsupportedError('Razorpay JS is only available on web.');
// }

// lib/payments/web_js_stub.dart
// Compiled for Android/iOS – keeps API shape consistent.
void openRazorpay(
  Map<String, dynamic> options, {
  void Function(Map<String, dynamic> resp)? onSuccess,
  void Function(Object err)? onError,
}) {
  throw UnsupportedError('Razorpay JS bridge is web-only.');
}
