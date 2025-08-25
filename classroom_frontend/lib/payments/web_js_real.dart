// // Only compiled on web (because of conditional import)
// import 'dart:js' as js;

// void openRazorpay(
//   Map<String, dynamic> options, {
//   void Function(Map<String, dynamic> resp)? onSuccess,
//   void Function(Object err)? onError,
// }) {
//   final razorpay = js.JsObject(js.context['Razorpay'], [
//     js.JsObject.jsify(options),
//   ]);

//   razorpay.callMethod('on', [
//     'payment.success',
//     js.allowInterop((resp) {
//       if (onSuccess != null) onSuccess(Map<String, dynamic>.from(resp));
//     }),
//   ]);

//   razorpay.callMethod('on', [
//     'payment.error',
//     js.allowInterop((err) {
//       if (onError != null) onError(err);
//     }),
//   ]);

//   razorpay.callMethod('open');
// }

// lib/payments/web_js_real.dart
// Compiled ONLY on web via conditional import in PaymentScreen
import 'dart:js' as js;

void openRazorpay(
  Map<String, dynamic> options, {
  void Function(Map<String, dynamic> resp)? onSuccess,
  void Function(Object err)? onError,
}) {
  final razorpay = js.JsObject(js.context['Razorpay'], [
    js.JsObject.jsify(options),
  ]);

  razorpay.callMethod('on', [
    'payment.success',
    js.allowInterop((resp) {
      if (onSuccess != null) onSuccess(Map<String, dynamic>.from(resp));
    }),
  ]);

  razorpay.callMethod('on', [
    'payment.error',
    js.allowInterop((err) {
      if (onError != null) onError(err);
    }),
  ]);

  razorpay.callMethod('open');
}
