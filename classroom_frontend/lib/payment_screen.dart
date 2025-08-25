// // import 'package:flutter/material.dart';
// // // import 'package:online_classes/core/constants/app_colors.dart';
// // // import 'package:online_classes/features/payment/presentation/widgets/payment_form.dart';

// // class PaymentScreen extends StatelessWidget {
// //   const PaymentScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.teal[300],
// //       appBar: AppBar(
// //         title: const Text('Student Payment'),
// //         backgroundColor: Colors.teal,
// //         foregroundColor: Colors.white,
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: PaymentForm(),
// //       ),
// //     );
// //   }
// // }

// // class PaymentForm extends StatelessWidget {
// //   const PaymentForm({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       child: Text("off"),
// //     );
// //   }
// // }

// //working starts

// // import 'dart:io' show Platform;
// // import 'dart:math';
// // import 'dart:js' as js; // for web Razorpay
// // import 'package:flutter/foundation.dart' show kIsWeb;
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';

// // import 'package:classroom_frontend/api_service.dart';
// // import 'package:classroom_frontend/BillingSummary_model.dart';
// // import 'package:classroom_frontend/PaymentRow_model.dart';

// // class PaymentScreen extends StatefulWidget {
// //   final String mobile;
// //   final String email;

// //   const PaymentScreen({super.key, required this.mobile, required this.email});

// //   @override
// //   State<PaymentScreen> createState() => _PaymentScreenState();
// // }

// // class _PaymentScreenState extends State<PaymentScreen> {
// //   static const int monthlyFeePaise = 49900; // ₹499.00
// //   late Future<BillingSummary> _future;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Fallbacks in case the caller forgot to pass (please wire properly in Dashboard)
// //     final mobile = (widget.mobile).isNotEmpty ? widget.mobile : '9998887777';
// //     _future = ApiService.fetchMyBilling(mobile);
// //   }

// //   Future<void> _reload() async {
// //     setState(() => _future = ApiService.fetchMyBilling(widget.mobile));
// //   }

// //   String _chipText(String s) {
// //     switch (s) {
// //       case 'trial':
// //         return 'Trial';
// //       case 'active':
// //         return 'Active';
// //       case 'expired':
// //         return 'Expired';
// //     }
// //     return s;
// //   }

// //   Color _chipColor(String s) {
// //     switch (s) {
// //       case 'trial':
// //         return Colors.orange;
// //       case 'active':
// //         return Colors.green;
// //       case 'expired':
// //         return Colors.redAccent;
// //       default:
// //         return Colors.grey;
// //     }
// //   }

// //   String _money(int paise) {
// //     // ₹ + 2 decimals
// //     return '₹ ${(paise / 100).toStringAsFixed(2)}';
// //   }

// //   String _when(DateTime? dt) {
// //     if (dt == null) return '—';
// //     return DateFormat('d MMM yyyy, h:mm a').format(dt);
// //     // If you want local timezone conversion, ensure server returns ISO8601 with Z or offset
// //   }

// //   Future<void> _payNow() async {
// //     try {
// //       // // 1) Create Razorpay order via BE
// //       // final order = await ApiService.createOrder(
// //       //   mobile: widget.mobile,
// //       //   amountPaise:monthlyFeePaise,
// //       // );

// //       // final orderId = order['order_id'] as String; // returned by your BE
// //       // final keyId = order['key'] as String; // publishable Razorpay key
// //       // final amount = (order['amount'] as num).toInt();
// //       // final currency = order['currency'] as String? ?? 'INR';

// //       // 1) Create Razorpay order via BE
// //       final order = await ApiService.createOrder(
// //         mobile: widget.mobile,
// //         amountPaise: monthlyFeePaise,
// //       );

// //       // Be defensive about keys coming back from BE
// //       final orderId = (order['order_id'] ?? order['id'])?.toString();
// //       final keyId = (order['key'] ?? order['key_id'])?.toString();
// //       final amount = (order['amount'] as num?)?.toInt();
// //       final currency = (order['currency'] ?? 'INR').toString();

// //       // Log to help debug quickly
// //       // ignore: avoid_print
// //       print('create-order response: $order');

// //       if (orderId == null || keyId == null || amount == null) {
// //         throw Exception(
// //           'Invalid order payload from server. '
// //           'Expected {order_id/key, amount, currency}. Got: $order',
// //         );
// //       }

// //       // if (kIsWeb) {
// //       //   // 2) Web checkout via JS (checkout.js already in web/index.html)
// //       //   final options = {
// //       //     'key': keyId,
// //       //     'amount': amount, // paise
// //       //     'currency': currency,
// //       //     'name': 'Online Classes',
// //       //     'description': 'Monthly Subscription',
// //       //     'order_id': orderId,
// //       //     'prefill': {'contact': widget.mobile, 'email': widget.email},
// //       //     'theme': {'color': '#13A0A4'},
// //       //     'handler': (js.JsObject response) {}, // placeholder; we attach below
// //       //   };

// //       //   // Attach success handler that calls /payments/confirm
// //       //   void handler(js.JsObject response) async {
// //       //     try {
// //       //       final paymentId = response['razorpay_payment_id'] as String;
// //       //       final signature = response['razorpay_signature'] as String;
// //       //       await ApiService.confirmPayment(
// //       //         mobile: widget.mobile,
// //       //         orderId: orderId,
// //       //         paymentId: paymentId,
// //       //         signature: signature,
// //       //       );
// //       //       if (!mounted) return;
// //       //       ScaffoldMessenger.of(context).showSnackBar(
// //       //         const SnackBar(content: Text('Payment successful!')),
// //       //       );
// //       //       _reload();
// //       //     } catch (e) {
// //       //       if (!mounted) return;
// //       //       ScaffoldMessenger.of(
// //       //         context,
// //       //       ).showSnackBar(SnackBar(content: Text('Confirm failed: $e')));
// //       //     }
// //       //   }

// //       //   // Build actual Razorpay instance and open
// //       //   final razorpay = js.JsObject(js.context['Razorpay'], [
// //       //     js.JsObject.jsify(options),
// //       //   ]);
// //       //   razorpay.callMethod('on', ['payment.success', (resp) => handler(resp)]);
// //       //   razorpay.callMethod('on', [
// //       //     'payment.error',
// //       //     (resp) {
// //       //       ScaffoldMessenger.of(context).showSnackBar(
// //       //         const SnackBar(content: Text('Payment cancelled/failed')),
// //       //       );
// //       //     },
// //       //   ]);
// //       //   razorpay.callMethod('open');
// //       // }
// //       if (kIsWeb) {
// //         // 2) Web checkout (checkout.js must be in web/index.html)
// //         final options = js.JsObject.jsify({
// //           'key': keyId,
// //           'amount': amount, // in paise
// //           'currency': currency,
// //           'name': 'Online Classes',
// //           'description': 'Monthly Subscription',
// //           'order_id': orderId,
// //           'prefill': {
// //             'contact': widget.mobile,
// //             'email': widget.email, // make sure this is a non-empty string
// //           },
// //           'theme': {'color': '#13A0A4'},

// //           // IMPORTANT: allowInterop so JS can call back into Dart
// //           'handler': js.allowInterop((dynamic resp) async {
// //             try {
// //               final paymentId = (resp['razorpay_payment_id'] ?? '').toString();
// //               final signature = (resp['razorpay_signature'] ?? '').toString();

// //               if (paymentId.isEmpty || signature.isEmpty) {
// //                 throw Exception('Missing payment confirmation fields: $resp');
// //               }

// //               await ApiService.confirmPayment(
// //                 mobile: widget.mobile,
// //                 orderId: orderId,
// //                 paymentId: paymentId,
// //                 signature: signature,
// //               );
// //               if (!mounted) return;
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 const SnackBar(content: Text('Payment successful!')),
// //               );
// //               _reload();
// //             } catch (e) {
// //               if (!mounted) return;
// //               ScaffoldMessenger.of(
// //                 context,
// //               ).showSnackBar(SnackBar(content: Text('Confirm failed: $e')));
// //             }
// //           }),
// //         });

// //         final razorpay = js.JsObject(js.context['Razorpay'], [options]);

// //         // Optional: error callback (also needs allowInterop)
// //         razorpay.callMethod('on', [
// //           'payment.error',
// //           js.allowInterop((dynamic resp) {
// //             ScaffoldMessenger.of(context).showSnackBar(
// //               SnackBar(
// //                 content: Text('Payment failed: ${resp?['error'] ?? 'unknown'}'),
// //               ),
// //             );
// //           }),
// //         ]);

// //         razorpay.callMethod('open');
// //       } else {
// //         // 2) Mobile (Android/iOS) — recommend package: razorpay_flutter
// //         // For now, show a helper dialog so you can still test server flow:
// //         if (!mounted) return;
// //         await showDialog<void>(
// //           context: context,
// //           builder: (_) => AlertDialog(
// //             title: const Text('Razorpay (mobile)'),
// //             content: Text(
// //               'Integrate the "razorpay_flutter" package to open the native checkout.\n\n'
// //               'TEMP TEST:\nSimulate success and we will call /payments/confirm '
// //               'with dummy ids.\n\norderId: $orderId\namount: ${_money(amount)}',
// //             ),
// //             actions: [
// //               TextButton(
// //                 onPressed: () => Navigator.pop(context),
// //                 child: const Text('Close'),
// //               ),
// //               ElevatedButton(
// //                 onPressed: () async {
// //                   Navigator.pop(context);
// //                   // Simulate a success
// //                   final fakePaymentId = 'pay_${Random().nextInt(99999999)}';
// //                   final fakeSignature = 'test_signature';
// //                   try {
// //                     await ApiService.confirmPayment(
// //                       mobile: widget.mobile,
// //                       orderId: orderId,
// //                       paymentId: fakePaymentId,
// //                       signature: fakeSignature,
// //                     );
// //                     if (!mounted) return;
// //                     ScaffoldMessenger.of(context).showSnackBar(
// //                       const SnackBar(
// //                         content: Text('Payment confirmed (simulated)'),
// //                       ),
// //                     );
// //                     _reload();
// //                   } catch (e) {
// //                     if (!mounted) return;
// //                     ScaffoldMessenger.of(context).showSnackBar(
// //                       SnackBar(content: Text('Confirm failed: $e')),
// //                     );
// //                   }
// //                 },
// //                 child: const Text('Simulate Success'),
// //               ),
// //             ],
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       if (!mounted) return;
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return FutureBuilder<BillingSummary>(
// //       future: _future,
// //       builder: (context, snap) {
// //         if (snap.connectionState == ConnectionState.waiting) {
// //           return const Scaffold(
// //             body: Center(child: CircularProgressIndicator()),
// //           );
// //         }
// //         if (snap.hasError) {
// //           return Scaffold(
// //             appBar: AppBar(
// //               title: const Text('Payments'),
// //               backgroundColor: const Color(0xFF13A0A4),
// //             ),
// //             body: Center(child: Text('Error: ${snap.error}')),
// //           );
// //         }
// //         final s = snap.data!;
// //         return Scaffold(
// //           appBar: AppBar(
// //             title: const Text('Payments'),
// //             backgroundColor: const Color(0xFF13A0A4),
// //             actions: [
// //               IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
// //             ],
// //           ),
// //           body: Container(
// //             decoration: const BoxDecoration(
// //               gradient: LinearGradient(
// //                 colors: [Color(0xFF13A0A4), Color(0xFF3CCACA)],
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //               ),
// //             ),
// //             child: ListView(
// //               padding: const EdgeInsets.all(16),
// //               children: [
// //                 // Status card
// //                 Card(
// //                   child: ListTile(
// //                     leading: Chip(
// //                       label: Text(
// //                         _chipText(s.status),
// //                         style: const TextStyle(fontWeight: FontWeight.w600),
// //                       ),
// //                       backgroundColor: _chipColor(s.status),
// //                     ),
// //                     title: Text(
// //                       s.status == 'active'
// //                           ? 'Paid until: ${_when(s.paidUntil)}'
// //                           : s.status == 'trial'
// //                           ? 'Trial ends: ${_when(s.trialEndsAt)}'
// //                           : 'Your plan is expired',
// //                     ),
// //                     subtitle: const Text('Plan: Monthly • ₹499'),
// //                     trailing: ElevatedButton(
// //                       onPressed: _payNow,
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: const Color(0xFFEE4C82),
// //                       ),
// //                       child: const Text('Pay Now'),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 12),
// //                 const Text(
// //                   'Payment History',
// //                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 if (s.history.isEmpty)
// //                   const Card(child: ListTile(title: Text('No payments yet')))
// //                 else
// //                   ...s.history.map(_historyTile),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _historyTile(PaymentRow r) {
// //     final statusColor =
// //         {
// //           'created': Colors.orange,
// //           'paid': Colors.green,
// //           'failed': Colors.red,
// //         }[r.status] ??
// //         Colors.grey;

// //     return Card(
// //       child: ListTile(
// //         leading: Icon(Icons.receipt_long, color: statusColor),
// //         title: Text('${_money(r.amount)} • ${r.currency}'),
// //         subtitle: Text(
// //           'Status: ${r.status} • Created: ${_when(r.createdAt)}'
// //           '${r.paidAt != null ? '\nPaid: ${_when(r.paidAt)}' : ''}',
// //         ),
// //       ),
// //     );
// //   }
// // }

// //working ends

// //import 'dart:io' show Platform;
// import 'dart:math';
// // ignore: avoid_web_libraries_in_flutter, deprecated_member_use
// import 'dart:js' as js;
// import 'package:classroom_frontend/MySubscription_model.dart';
// import 'package:classroom_frontend/offering_model.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import 'package:classroom_frontend/api_service.dart';

// class PaymentScreen extends StatefulWidget {
//   final String mobile;
//   final String email;
//   const PaymentScreen({super.key, required this.mobile, required this.email});

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   List<Offering> _offerings = [];
//   List<MySubscription> _subs = [];
//   String? _selectedSubject;
//   Offering? _selectedOffering;
//   bool _loading = true;

//   late Future<Map<String, dynamic>> _future;

//   @override
//   void initState() {
//     super.initState();
//     // _boot();
//     _future = ApiService.fetchMyBillingRaw(widget.mobile);
//   }

//   Future<void> _reload() async {
//     setState(() => _future = ApiService.fetchMyBillingRaw(widget.mobile));
//   }

//   Future<void> _payNow() async {
//     try {
//       final order = await ApiService.createOrderPerLecture(
//         mobile: widget.mobile,
//       );
//       final orderId = order['order_id'] as String;
//       final keyId = order['key'] as String;
//       final amount = (order['amount'] as num).toInt();
//       final currency = order['currency'] as String? ?? 'INR';

//       if (kIsWeb) {
//         final options = {
//           'key': keyId,
//           'amount': amount,
//           'currency': currency,
//           'name': 'Online Classes',
//           'description': 'Per-lecture billing',
//           'order_id': orderId,
//           'prefill': {
//             'contact': widget.mobile,
//             'email': (widget.email.isNotEmpty
//                 ? widget.email
//                 : 'noreply@example.com'),
//           },
//           // 'prefill': {'contact': widget.mobile, 'email': widget.email},
//           'theme': {'color': '#13A0A4'},
//         };

//         final razorpay = js.JsObject(js.context['Razorpay'], [
//           js.JsObject.jsify(options),
//         ]);
//         razorpay.callMethod('on', [
//           'payment.success',
//           js.allowInterop((resp) async {
//             // <-- allowInterop
//             try {
//               final paymentId = (resp['razorpay_payment_id'] ?? '').toString();
//               final signature = (resp['razorpay_signature'] ?? '').toString();
//               await ApiService.confirmPayment(
//                 mobile: widget.mobile,
//                 orderId: orderId,
//                 paymentId: paymentId,
//                 signature: signature,
//               );
//               if (!mounted) return;
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Payment successful!')),
//               );
//               _reload();
//             } catch (e) {
//               if (!mounted) return;
//               ScaffoldMessenger.of(
//                 context,
//               ).showSnackBar(SnackBar(content: Text('Confirm failed: $e')));
//             }
//           }),
//           // (resp) async {
//           //   try {
//           //     await ApiService.confirmPayment(
//           //       mobile: widget.mobile,
//           //       orderId: orderId,
//           //       paymentId: resp['razorpay_payment_id'],
//           //       signature: resp['razorpay_signature'],
//           //     );
//           //     if (!mounted) return;
//           //     ScaffoldMessenger.of(context).showSnackBar(
//           //       const SnackBar(content: Text('Payment successful!')),
//           //     );
//           //     _reload();
//           //   } catch (e) {
//           //     if (!mounted) return;
//           //     ScaffoldMessenger.of(
//           //       context,
//           //     ).showSnackBar(SnackBar(content: Text('Confirm failed: $e')));
//           //   }
//           // },
//         ]);
//         razorpay.callMethod('on', [
//           'payment.error',
//           js.allowInterop((_) {
//             // <-- allowInterop
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Payment cancelled/failed')),
//             );
//           }),
//           // (_) {
//           //   ScaffoldMessenger.of(context).showSnackBar(
//           //     const SnackBar(content: Text('Payment cancelled/failed')),
//           //   );
//           // },
//         ]);
//         razorpay.callMethod('open');
//       } else {
//         // native: replace with razorpay_flutter; keep your simulate dialog for now
//         // (same as before, but do not pass custom amount from app)
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
//     }
//   }

//   Widget _subjectBreakdown(Map<String, dynamic> bySubject) {
//     if (bySubject.isEmpty) {
//       return const Card(child: ListTile(title: Text('No pending lectures')));
//     }
//     return Column(
//       children: bySubject.entries.map((e) {
//         return Card(
//           child: ListTile(
//             leading: const Icon(Icons.book),
//             title: Text(e.key),
//             trailing: Text('${e.value}'),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Future<void> _boot() async {
//     try {
//       final offers = await ApiService.fetchOfferings();
//       final subs = await ApiService.fetchMySubscriptions(widget.mobile);

//       // Default subject: first available
//       String? subject;
//       if (offers.isNotEmpty) subject = offers.first.subject;

//       setState(() {
//         _offerings = offers;
//         _subs = subs;
//         _selectedSubject = subject;
//         _selectedOffering = _offersForSubject(subject).isNotEmpty
//             ? _offersForSubject(subject).first
//             : null;
//         _loading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => _loading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Load failed: $e')));
//     }
//   }

//   List<String> _subjects() =>
//       _offerings.map((o) => o.subject).toSet().toList()..sort();

//   List<Offering> _offersForSubject(String? subject) =>
//       _offerings.where((o) => o.subject == subject).toList();

//   String _money(int paise) => '₹ ${(paise / 100).toStringAsFixed(2)}';

//   String _date(DateTime d) => DateFormat('d MMM yyyy').format(d);

//   // Future<void> _payNow() async {
//   //   final off = _selectedOffering;
//   //   if (off == null) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text('Please select a subject & teacher')),
//   //     );
//   //     return;
//   //   }

//   //   try {
//   //     final order = await ApiService.createOrderForOffering(
//   //       mobile: widget.mobile,
//   //       offeringId: off.id,
//   //     );

//   //     final orderId = (order['order_id'] ?? order['id'])?.toString();
//   //     final keyId = (order['key'] ?? order['key_id'])?.toString();
//   //     final amount = (order['amount'] as num?)?.toInt();
//   //     final currency = (order['currency'] ?? 'INR').toString();

//   //     if (orderId == null || keyId == null || amount == null) {
//   //       throw Exception('Invalid order payload from server: $order');
//   //     }

//   //     final safeEmail = widget.email.isNotEmpty
//   //         ? widget.email
//   //         : 'noreply@example.com';

//   //     if (kIsWeb) {
//   //       final options = js.JsObject.jsify({
//   //         'key': keyId,
//   //         'amount': amount,
//   //         'currency': currency,
//   //         'name': 'Online Classes',
//   //         'description': '${off.subject} • ${off.teacherMobile}',
//   //         'order_id': orderId,
//   //         'prefill': {'contact': widget.mobile, 'email': safeEmail},
//   //         'theme': {'color': '#13A0A4'},
//   //         'handler': js.allowInterop((dynamic resp) async {
//   //           try {
//   //             final paymentId = (resp['razorpay_payment_id'] ?? '').toString();
//   //             final signature = (resp['razorpay_signature'] ?? '').toString();
//   //             if (paymentId.isEmpty || signature.isEmpty) {
//   //               throw Exception('Missing payment fields: $resp');
//   //             }
//   //             await ApiService.confirmPayment(
//   //               mobile: widget.mobile,
//   //               orderId: orderId,
//   //               paymentId: paymentId,
//   //               signature: signature,
//   //             );
//   //             if (!mounted) return;
//   //             ScaffoldMessenger.of(context).showSnackBar(
//   //               const SnackBar(content: Text('Payment successful!')),
//   //             );
//   //             _boot();
//   //           } catch (e) {
//   //             if (!mounted) return;
//   //             ScaffoldMessenger.of(
//   //               context,
//   //             ).showSnackBar(SnackBar(content: Text('Confirm failed: $e')));
//   //           }
//   //         }),
//   //       });

//   //       final razorpay = js.JsObject(js.context['Razorpay'], [options]);
//   //       razorpay.callMethod('on', [
//   //         'payment.error',
//   //         js.allowInterop((dynamic resp) {
//   //           ScaffoldMessenger.of(context).showSnackBar(
//   //             const SnackBar(content: Text('Payment cancelled/failed')),
//   //           );
//   //         }),
//   //       ]);
//   //       razorpay.callMethod('open');
//   //     } else {
//   //       // mobile: integrate razorpay_flutter; temporary simulator:
//   //       await showDialog<void>(
//   //         context: context,
//   //         builder: (_) => AlertDialog(
//   //           title: const Text('Razorpay (mobile)'),
//   //           content: Text(
//   //             'Simulate success for:\n${off.subject} • ${off.teacherMobile}\n'
//   //             'Order: $orderId\nAmount: ${_money(amount)}',
//   //           ),
//   //           actions: [
//   //             TextButton(
//   //               onPressed: () => Navigator.pop(context),
//   //               child: const Text('Close'),
//   //             ),
//   //             ElevatedButton(
//   //               onPressed: () async {
//   //                 Navigator.pop(context);
//   //                 final fakePaymentId = 'pay_${Random().nextInt(99999999)}';
//   //                 final fakeSignature = 'test_signature';
//   //                 await ApiService.confirmPayment(
//   //                   mobile: widget.mobile,
//   //                   orderId: orderId,
//   //                   paymentId: fakePaymentId,
//   //                   signature: fakeSignature,
//   //                 );
//   //                 if (!mounted) return;
//   //                 ScaffoldMessenger.of(context).showSnackBar(
//   //                   const SnackBar(
//   //                     content: Text('Payment confirmed (simulated)'),
//   //                   ),
//   //                 );
//   //                 _boot();
//   //               },
//   //               child: const Text('Simulate Success'),
//   //             ),
//   //           ],
//   //         ),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     if (!mounted) return;
//   //     ScaffoldMessenger.of(
//   //       context,
//   //     ).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _future,
//       builder: (_, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         if (snap.hasError) {
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text('Payments'),
//               backgroundColor: const Color(0xFF13A0A4),
//             ),
//             body: Center(child: Text('Error: ${snap.error}')),
//           );
//         }

//         final data = snap.data!;
//         final pending = data['pending'] as Map<String, dynamic>;
//         final bySubject = Map<String, dynamic>.from(
//           pending['by_subject'] as Map,
//         );
//         final totalLectures = (pending['total_lectures'] as num).toInt();
//         final amountPaise = (pending['amount_paise'] as num).toInt();
//         final ratePaise = (data['rate_paise'] as num).toInt();

//         String money(int p) => '₹ ${(p / 100).toStringAsFixed(2)}';

//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Payments'),
//             backgroundColor: const Color(0xFF13A0A4),
//             actions: [
//               IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
//             ],
//           ),
//           body: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF13A0A4), Color(0xFF3CCACA)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 Card(
//                   child: ListTile(
//                     title: Text('Pending: $totalLectures lecture(s)'),
//                     subtitle: Text(
//                       'Rate: ${money(ratePaise)} • Amount due: ${money(amountPaise)}',
//                     ),
//                     trailing: ElevatedButton(
//                       onPressed: totalLectures > 0 ? _payNow : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFEE4C82),
//                       ),
//                       child: const Text('Pay Now'),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 const Text(
//                   'Breakdown by Subject',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 _subjectBreakdown(bySubject),

//                 const SizedBox(height: 12),
//                 const Text(
//                   'Payment History',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 // use your existing history UI (from invoices)
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   if (_loading) {
//   //     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   //   }

//   //   final subjects = _subjects();
//   //   final offers = _offersForSubject(_selectedSubject);

//   //   return Scaffold(
//   //     appBar: AppBar(
//   //       title: const Text('Payments'),
//   //       backgroundColor: const Color(0xFF13A0A4),
//   //       actions: [
//   //         IconButton(onPressed: _boot, icon: const Icon(Icons.refresh)),
//   //       ],
//   //     ),
//   //     body: Container(
//   //       decoration: const BoxDecoration(
//   //         gradient: LinearGradient(
//   //           colors: [Color(0xFF13A0A4), Color(0xFF3CCACA)],
//   //           begin: Alignment.topLeft,
//   //           end: Alignment.bottomRight,
//   //         ),
//   //       ),
//   //       child: ListView(
//   //         padding: const EdgeInsets.all(16),
//   //         children: [
//   //           // Active subscriptions
//   //           Card(
//   //             child: Padding(
//   //               padding: const EdgeInsets.all(12),
//   //               child: Column(
//   //                 crossAxisAlignment: CrossAxisAlignment.start,
//   //                 children: [
//   //                   const Text(
//   //                     'Your active access',
//   //                     style: TextStyle(fontWeight: FontWeight.bold),
//   //                   ),
//   //                   const SizedBox(height: 8),
//   //                   if (_subs.isEmpty)
//   //                     const Text('None yet')
//   //                   else
//   //                     ..._subs.map(
//   //                       (s) => ListTile(
//   //                         leading: const Icon(
//   //                           Icons.check_circle,
//   //                           color: Colors.green,
//   //                         ),
//   //                         title: Text('${s.subject} • ${s.teacherMobile}'),
//   //                         subtitle: Text(
//   //                           'Valid till ${_date(s.validTo)} (${s.status})',
//   //                         ),
//   //                       ),
//   //                     ),
//   //                 ],
//   //               ),
//   //             ),
//   //           ),
//   //           const SizedBox(height: 12),
//   //           // Purchase form
//   //           Card(
//   //             child: Padding(
//   //               padding: const EdgeInsets.all(12),
//   //               child: Column(
//   //                 children: [
//   //                   const Align(
//   //                     alignment: Alignment.centerLeft,
//   //                     child: Text(
//   //                       'Buy access',
//   //                       style: TextStyle(fontWeight: FontWeight.bold),
//   //                     ),
//   //                   ),
//   //                   const SizedBox(height: 8),
//   //                   DropdownButtonFormField<String>(
//   //                     value: _selectedSubject,
//   //                     decoration: const InputDecoration(
//   //                       labelText: 'Subject',
//   //                       border: OutlineInputBorder(),
//   //                     ),
//   //                     items: subjects
//   //                         .map(
//   //                           (s) => DropdownMenuItem(value: s, child: Text(s)),
//   //                         )
//   //                         .toList(),
//   //                     onChanged: (v) => setState(() {
//   //                       _selectedSubject = v;
//   //                       final list = _offersForSubject(v);
//   //                       _selectedOffering = list.isNotEmpty ? list.first : null;
//   //                     }),
//   //                   ),
//   //                   const SizedBox(height: 10),
//   //                   DropdownButtonFormField<Offering>(
//   //                     value: _selectedOffering,
//   //                     decoration: const InputDecoration(
//   //                       labelText: 'Teacher',
//   //                       border: OutlineInputBorder(),
//   //                     ),
//   //                     items: offers
//   //                         .map(
//   //                           (o) => DropdownMenuItem(
//   //                             value: o,
//   //                             child: Text(o.teacherMobile),
//   //                           ),
//   //                         )
//   //                         .toList(),
//   //                     onChanged: (v) => setState(() => _selectedOffering = v),
//   //                   ),
//   //                   const SizedBox(height: 10),
//   //                   if (_selectedOffering != null)
//   //                     Align(
//   //                       alignment: Alignment.centerLeft,
//   //                       child: Text(
//   //                         'Price: ${_money(_selectedOffering!.pricePaise)} / month',
//   //                         style: const TextStyle(fontWeight: FontWeight.w600),
//   //                       ),
//   //                     ),
//   //                   const SizedBox(height: 12),
//   //                   SizedBox(
//   //                     width: double.infinity,
//   //                     child: ElevatedButton(
//   //                       onPressed: _payNow,
//   //                       style: ElevatedButton.styleFrom(
//   //                         backgroundColor: const Color(0xFFEE4C82),
//   //                       ),
//   //                       child: const Text('Pay Now'),
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
// }

// lib/screens/payment_screen.dart
// A robust version that won’t crash on unexpected JSON shapes.

// import 'dart:js' as js; // ignore: avoid_web_libraries_in_flutter
// import 'package:classroom_frontend/PaymentRow_model.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../api_service.dart';

// class PaymentScreen extends StatefulWidget {
//   final String mobile;
//   final String email;
//   const PaymentScreen({super.key, required this.mobile, required this.email});

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   late Future<Map<String, dynamic>> _future;

//   @override
//   void initState() {
//     super.initState();
//     _future = ApiService.fetchMyBillingRaw(widget.mobile);
//   }

//   Future<void> _reload() async {
//     setState(() => _future = ApiService.fetchMyBillingRaw(widget.mobile));
//   }

//   String _money(int paise) => '₹ ${(paise / 100).toStringAsFixed(2)}';

//   // Widget _subjectBreakdown(Map<String, int> bySubject) {
//   //   if (bySubject.isEmpty) {
//   //     return const Card(child: ListTile(title: Text('No pending lectures')));
//   //   }
//   //   return Column(
//   //     children: bySubject.entries.map((e) {
//   //       return Card(
//   //         child: ListTile(
//   //           leading: const Icon(Icons.book),
//   //           title: Text(e.key),
//   //           trailing: Text('${e.value}'),
//   //         ),
//   //       );
//   //     }).toList(),
//   //   );
//   // }

//   Widget _subjectBreakdown(dynamic bySubjectRaw) {
//     // backend now returns a List of objects
//     final items = (bySubjectRaw as List).cast<dynamic>();
//     if (items.isEmpty) {
//       return const Card(child: ListTile(title: Text('No pending lectures')));
//     }
//     String money(int p) => '₹ ${(p / 100).toStringAsFixed(2)}';
//     return Column(
//       children: items.map((e) {
//         final m = Map<String, dynamic>.from(e as Map);
//         final title = '${m['subjectname']} • ${m['teacher_mobile']}';
//         final sub =
//             'Lectures: ${m['count']} • Rate: ${money((m['rate_paise'] as num).toInt())}';
//         final trailing = money((m['amount_paise'] as num).toInt());
//         return Card(
//           child: ListTile(
//             leading: const Icon(Icons.book),
//             title: Text(title),
//             subtitle: Text(sub),
//             trailing: Text(trailing),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Future<void> _payNow() async {
//     try {
//       final order = await ApiService.createOrderPerLecture(
//         mobile: widget.mobile,
//       );

//       final orderId = (order['order_id'] ?? '').toString();
//       final keyId = (order['key'] ?? '').toString();
//       final amount = (order['amount'] as num?)?.toInt() ?? 0;
//       final currency = (order['currency'] ?? 'INR').toString();

//       if (orderId.isEmpty || keyId.isEmpty || amount <= 0) {
//         throw Exception('Bad order payload: $order');
//       }

//       if (kIsWeb) {
//         final options = {
//           'key': keyId,
//           'amount': amount,
//           'currency': currency,
//           'name': 'Online Classes',
//           'description': 'Per-lecture billing',
//           'order_id': orderId,
//           'prefill': {
//             'contact': widget.mobile,
//             'email': widget.email.isNotEmpty
//                 ? widget.email
//                 : 'noreply@example.com',
//           },
//           'theme': {'color': '#13A0A4'},
//         };

//         final razorpay = js.JsObject(js.context['Razorpay'], [
//           js.JsObject.jsify(options),
//         ]);

//         razorpay.callMethod('on', [
//           'payment.success',
//           js.allowInterop((resp) async {
//             try {
//               final paymentId = (resp['razorpay_payment_id'] ?? '').toString();
//               final signature = (resp['razorpay_signature'] ?? '').toString();
//               await ApiService.confirmPayment(
//                 mobile: widget.mobile,
//                 orderId: orderId,
//                 paymentId: paymentId,
//                 signature: signature,
//               );
//               if (!mounted) return;
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Payment successful!')),
//               );
//               _reload();
//             } catch (e) {
//               if (!mounted) return;
//               ScaffoldMessenger.of(
//                 context,
//               ).showSnackBar(SnackBar(content: Text('Confirm failed: $e')));
//             }
//           }),
//         ]);

//         razorpay.callMethod('on', [
//           'payment.error',
//           js.allowInterop((_) {
//             if (!mounted) return;
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Payment cancelled/failed')),
//             );
//           }),
//         ]);

//         razorpay.callMethod('open');
//       } else {
//         // If you hook up the mobile plugin later, handle it here.
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _future,
//       builder: (_, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         if (snap.hasError) {
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text('Payments'),
//               backgroundColor: const Color(0xFF13A0A4),
//             ),
//             body: Padding(
//               padding: const EdgeInsets.all(16),
//               child: SelectableText('Error: ${snap.error}'),
//             ),
//           );
//         }

//         // final data = snap.data ?? const {};
//         // // Defensive decoding to avoid "List is not a subtype of Map" crashes
//         // final pendingDyn = data['pending'];
//         // if (pendingDyn is! Map) {
//         //   return Scaffold(
//         //     appBar: AppBar(
//         //       title: const Text('Payments'),
//         //       backgroundColor: const Color(0xFF13A0A4),
//         //     ),
//         //     body: Padding(
//         //       padding: const EdgeInsets.all(16),
//         //       child: Text(
//         //         'Unexpected server response for "pending": ${pendingDyn.runtimeType}',
//         //       ),
//         //     ),
//         //   );
//         // }
//         // final pending = Map<String, dynamic>.from(pendingDyn);

//         // final bySubjectDyn = pending['by_subject'];
//         // final bySubject = <String, int>{};
//         // if (bySubjectDyn is Map) {
//         //   for (final e in bySubjectDyn.entries) {
//         //     final k = e.key.toString();
//         //     final v = (e.value as num?)?.toInt() ?? 0;
//         //     bySubject[k] = v;
//         //   }
//         // }

//         // final totalLectures = (pending['total_lectures'] as num? ?? 0).toInt();
//         // final amountPaise = (pending['amount_paise'] as num? ?? 0).toInt();
//         // final ratePaise = (data['rate_paise'] as num? ?? 0).toInt();

//         // final historyListDyn = data['history'];
//         // final history = <PaymentRow>[];
//         // if (historyListDyn is List) {
//         //   for (final h in historyListDyn) {
//         //     if (h is Map<String, dynamic>) {
//         //       history.add(PaymentRow.fromJson(h));
//         //     }
//         //   }
//         // }

//         // final pending = data['pending'] as Map<String, dynamic>;
//         // final bySubject = (pending['by_subject'] as List);

//         final data = snap.data ?? const {};

//         // --- defensive read of "pending" ---
//         final pendingDyn = data['pending'];
//         if (pendingDyn is! Map) {
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text('Payments'),
//               backgroundColor: const Color(0xFF13A0A4),
//             ),
//             body: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 'Unexpected server response for "pending": ${pendingDyn.runtimeType}',
//               ),
//             ),
//           );
//         }
//         final pending = Map<String, dynamic>.from(pendingDyn);

//         // totals from backend
//         final totalLectures = (pending['total_lectures'] as num? ?? 0).toInt();
//         final amountPaise = (pending['amount_paise'] as num? ?? 0).toInt();

//         // NEW: backend returns a **List** for by_subject
//         final bySubjectList = (pending['by_subject'] as List?) ?? [];

//         // Optional: fallback rate (used only if an offering is missing a price)
//         // NOTE: Not a single global rate anymore; keep it if you want to show a hint
//         final fallbackRatePaise = (pending['fallback_rate'] as num? ?? 0)
//             .toInt();

//         // payment history
//         final history = <PaymentRow>[];
//         final historyListDyn = data['history'];
//         if (historyListDyn is List) {
//           for (final h in historyListDyn) {
//             if (h is Map<String, dynamic>) {
//               history.add(PaymentRow.fromJson(h));
//             }
//           }
//         }

//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Payments'),
//             backgroundColor: const Color(0xFF13A0A4),
//             actions: [
//               IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
//             ],
//           ),
//           body: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF13A0A4), Color(0xFF3CCACA)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 Card(
//                   child: ListTile(
//                     title: Text('Pending: $totalLectures lecture(s)'),
//                     subtitle: Text(
//                       // 'Rate: ${_money(ratePaise)} • Amount due: ${_money(amountPaise)}',
//                       'Amount due: ${_money(amountPaise)}',
//                     ),
//                     trailing: ElevatedButton(
//                       onPressed: totalLectures > 0 ? _payNow : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFEE4C82),
//                       ),
//                       child: const Text('Pay Now'),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 const Text(
//                   'Breakdown by Subject',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 _subjectBreakdown(bySubjectList),

//                 // _subjectBreakdown(bySubject),
//                 const SizedBox(height: 12),
//                 const Text(
//                   'Payment History',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 if (history.isEmpty)
//                   const Card(child: ListTile(title: Text('No payments yet')))
//                 else
//                   ...history.map(
//                     (p) => Card(
//                       child: ListTile(
//                         leading: const Icon(Icons.receipt_long),
//                         title: Text(
//                           '${p.status.toUpperCase()} • ${_money(p.amount)}',
//                         ),
//                         subtitle: Text(
//                           DateFormat('d MMM yyyy, hh:mm a').format(p.createdAt),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

//working starts
// // import 'dart:js' as js;
// import 'package:classroom_frontend/PaymentRow_model.dart';
// import 'package:classroom_frontend/offering_model.dart';
// import 'package:classroom_frontend/subject_screen.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../api_service.dart';

// class PaymentScreen extends StatefulWidget {
//   final String mobile;
//   final String email;
//   const PaymentScreen({super.key, required this.mobile, required this.email});

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   late Future<Map<String, dynamic>> _future;
//   late Future<List<Offering>> _offeringsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _future = ApiService.fetchMyBillingRaw(widget.mobile);
//     _offeringsFuture = ApiService.fetchOfferings(mobile: widget.mobile);
//     //_offeringsFuture = ApiService.fetchOfferings(); // ALL subjects
//   }

//   Future<void> _reload() async {
//     setState(() {
//       _future = ApiService.fetchMyBillingRaw(widget.mobile);
//       // _offeringsFuture = ApiService.fetchOfferings();
//       _offeringsFuture = ApiService.fetchOfferings(mobile: widget.mobile);
//     });
//   }

//   String _money(int paise) => '₹ ${(paise / 100).toStringAsFixed(2)}';

//   Widget _subjectBreakdown(dynamic bySubjectRaw) {
//     final items = (bySubjectRaw as List?)?.cast<dynamic>() ?? [];
//     if (items.isEmpty) {
//       return const Card(child: ListTile(title: Text('No pending lectures')));
//     }
//     String money(int p) => '₹ ${(p / 100).toStringAsFixed(2)}';
//     return Column(
//       children: items.map((e) {
//         final m = Map<String, dynamic>.from(e as Map);
//         final title = '${m['subjectname']} • ${m['teacher_mobile']}';
//         final sub =
//             'Lectures: ${m['count']} • Rate: ${money((m['rate_paise'] as num).toInt())}';
//         final trailing = money((m['amount_paise'] as num).toInt());
//         return Card(
//           child: ListTile(
//             leading: const Icon(Icons.book),
//             title: Text(title),
//             subtitle: Text(sub),
//             trailing: Text(trailing),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Future<void> _payNow() async {
//     try {
//       final order = await ApiService.createOrderPerLecture(
//         mobile: widget.mobile,
//       );

//       final orderId = (order['order_id'] ?? '').toString();
//       final keyId = (order['key'] ?? '').toString();
//       final amount = (order['amount'] as num?)?.toInt() ?? 0;
//       final currency = (order['currency'] ?? 'INR').toString();

//       if (orderId.isEmpty || keyId.isEmpty || amount <= 0) {
//         throw Exception('Bad order payload: $order');
//       }

//       if (kIsWeb) {
//         final options = {
//           'key': keyId,
//           'amount': amount,
//           'currency': currency,
//           'name': 'Online Classes',
//           'description': 'Per-lecture billing',
//           'order_id': orderId,
//           'prefill': {
//             'contact': widget.mobile,
//             'email': widget.email.isNotEmpty
//                 ? widget.email
//                 : 'noreply@example.com',
//           },
//           'theme': {'color': '#13A0A4'},
//         };

//         final razorpay = js.JsObject(js.context['Razorpay'], [
//           js.JsObject.jsify(options),
//         ]);

//         razorpay.callMethod('on', [
//           'payment.success',
//           js.allowInterop((resp) async {
//             try {
//               final paymentId = (resp['razorpay_payment_id'] ?? '').toString();
//               final signature = (resp['razorpay_signature'] ?? '').toString();
//               await ApiService.confirmPayment(
//                 mobile: widget.mobile,
//                 orderId: orderId,
//                 paymentId: paymentId,
//                 signature: signature,
//               );
//               if (!mounted) return;
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Payment successful!')),
//               );
//               _reload();
//             } catch (e) {
//               if (!mounted) return;
//               ScaffoldMessenger.of(
//                 context,
//               ).showSnackBar(SnackBar(content: Text('Confirm failed: $e')));
//             }
//           }),
//         ]);

//         razorpay.callMethod('on', [
//           'payment.error',
//           js.allowInterop((_) {
//             if (!mounted) return;
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Payment cancelled/failed')),
//             );
//           }),
//         ]);

//         razorpay.callMethod('open');
//       } else {
//         // hook up mobile plugin later if you need
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _future,
//       builder: (_, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         if (snap.hasError) {
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text('Payments'),
//               backgroundColor: const Color(0xFF13A0A4),
//             ),
//             body: Padding(
//               padding: const EdgeInsets.all(16),
//               child: SelectableText('Error: ${snap.error}'),
//             ),
//           );
//         }

//         final data = snap.data ?? const {};
//         final pendingDyn = data['pending'];
//         if (pendingDyn is! Map) {
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text('Payments'),
//               backgroundColor: const Color(0xFF13A0A4),
//             ),
//             body: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 'Unexpected server response for "pending": ${pendingDyn.runtimeType}',
//               ),
//             ),
//           );
//         }
//         final pending = Map<String, dynamic>.from(pendingDyn);

//         final totalLectures = (pending['total_lectures'] as num? ?? 0).toInt();
//         final amountPaise = (pending['amount_paise'] as num? ?? 0).toInt();

//         // backend now returns List for by_subject
//         final bySubjectList = (pending['by_subject'] as List?) ?? [];

//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Payments'),
//             backgroundColor: const Color(0xFF13A0A4),
//             actions: [
//               IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
//             ],
//           ),
//           body: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF13A0A4), Color(0xFF3CCACA)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 Card(
//                   child: ListTile(
//                     title: Text('Pending: $totalLectures lecture(s)'),
//                     subtitle: Text('Amount due: ${_money(amountPaise)}'),
//                     trailing: ElevatedButton(
//                       onPressed: totalLectures > 0 ? _payNow : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFEE4C82),
//                       ),
//                       child: const Text('Pay Now'),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 const Text(
//                   'Breakdown by Subject (Pending)',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 _subjectBreakdown(bySubjectList),

//                 const SizedBox(height: 20),
//                 const Divider(),
//                 const SizedBox(height: 12),

//                 // NEW: ALL SUBJECTS the student can choose to sit for
//                 const Text(
//                   'Available Subjects (All)',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),

//                 FutureBuilder<List<Offering>>(
//                   future: _offeringsFuture,
//                   builder: (_, subsnap) {
//                     if (subsnap.connectionState == ConnectionState.waiting) {
//                       return const Center(
//                         child: Padding(
//                           padding: EdgeInsets.all(16),
//                           child: CircularProgressIndicator(),
//                         ),
//                       );
//                     }
//                     if (subsnap.hasError) {
//                       return Padding(
//                         padding: const EdgeInsets.all(8),
//                         child: Text(
//                           'Failed to load subjects: ${subsnap.error}',
//                         ),
//                       );
//                     }
//                     final offerings = subsnap.data ?? const [];
//                     if (offerings.isEmpty) {
//                       return const Card(
//                         child: ListTile(title: Text('No subjects created yet')),
//                       );
//                     }
//                     String money(int p) => '₹ ${(p / 100).toStringAsFixed(0)}';
//                     // return Column(
//                     //   children: offerings.map((o) {
//                     //     return Card(
//                     //       child: ListTile(
//                     //         leading: const Icon(Icons.menu_book),
//                     //         title: Text(o.subjectname),
//                     //         subtitle: Text(
//                     //           'Teacher: ${o.teacherMobile} • Rate: ${money(o.pricePaise)}',
//                     //         ),
//                     //         // trailing: ElevatedButton(
//                     //         //   onPressed: () {
//                     //         //     // jump to classroom filtered to this subject+teacher
//                     //         //     Navigator.push(
//                     //         //       context,
//                     //         //       MaterialPageRoute(
//                     //         //         builder: (_) => SubjectListScreen(
//                     //         //           role: 'student',
//                     //         //           teacherMobile:
//                     //         //               widget.mobile, // keep backward compat
//                     //         //           studentMobile:
//                     //         //               widget.mobile, // real student mobile
//                     //         //           offeringFilter:
//                     //         //               o, // filter by this subject+teacher
//                     //         //         ),
//                     //         //       ),
//                     //         //     );
//                     //         //   },
//                     //         //   child: const Text('View classes'),
//                     //         // ),
//                     //         trailing: ElevatedButton(
//                     //           onPressed: () async {
//                     //             if (m['enrolled'] == true) {
//                     //               // Call unenroll API
//                     //               await ApiService.unenrollSubject(
//                     //                 mobile: widget.mobile,
//                     //                 subjectId: m['id'],
//                     //               );
//                     //               _reload();
//                     //             } else {
//                     //               // Call enroll API
//                     //               await ApiService.enrollSubject(
//                     //                 mobile: widget.mobile,
//                     //                 subjectId: m['id'],
//                     //               );
//                     //               _reload();
//                     //             }
//                     //           },
//                     //           style: ElevatedButton.styleFrom(
//                     //             backgroundColor: m['enrolled'] == true
//                     //                 ? Colors.red
//                     //                 : Colors.green,
//                     //           ),
//                     //           child: Text(
//                     //             m['enrolled'] == true ? 'Unenroll' : 'Enroll',
//                     //           ),
//                     //         ),
//                     //       ),
//                     //     );
//                     //   }).toList(),
//                     // );

//                     return Column(
//                       children: offerings.map((o) {
//                         final isEnrolled = o.enrolled; // <— from model
//                         return Card(
//                           child: ListTile(
//                             leading: const Icon(Icons.menu_book),
//                             title: Text(o.subjectname),
//                             subtitle: Text(
//                               'Teacher: ${o.teacherMobile} • Rate: ${money(o.pricePaise)}',
//                             ),
//                             trailing: ElevatedButton(
//                               onPressed: () async {
//                                 try {
//                                   if (isEnrolled) {
//                                     await ApiService.unenrollSubject(
//                                       mobile: widget.mobile,
//                                       subjectId: o.id,
//                                     );
//                                   } else {
//                                     await ApiService.enrollSubject(
//                                       mobile: widget.mobile,
//                                       subjectId: o.id,
//                                     );
//                                   }
//                                   _reload();
//                                 } catch (e) {
//                                   if (!mounted) return;
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text('Action failed: $e'),
//                                     ),
//                                   );
//                                 }
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: isEnrolled
//                                     ? Colors.red
//                                     : Colors.green,
//                               ),
//                               child: Text(isEnrolled ? 'Unenroll' : 'Enroll'),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 20),
//                 const Divider(),
//                 const SizedBox(height: 12),

//                 const Text(
//                   'Payment History',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),

//                 // history is still returned by your backend if you add it
//                 // (left as-is; show empty when not provided)
//                 Builder(
//                   builder: (_) {
//                     final historyListDyn = data['history'];
//                     final history = <PaymentRow>[];
//                     if (historyListDyn is List) {
//                       for (final h in historyListDyn) {
//                         if (h is Map<String, dynamic>) {
//                           history.add(PaymentRow.fromJson(h));
//                         }
//                       }
//                     }
//                     if (history.isEmpty) {
//                       return const Card(
//                         child: ListTile(title: Text('No payments yet')),
//                       );
//                     }
//                     return Column(
//                       children: history
//                           .map(
//                             (p) => Card(
//                               child: ListTile(
//                                 leading: const Icon(Icons.receipt_long),
//                                 title: Text(
//                                   '${p.status.toUpperCase()} • ${_money(p.amount)}',
//                                 ),
//                                 subtitle: Text(
//                                   DateFormat(
//                                     'd MMM yyyy, hh:mm a',
//                                   ).format(p.createdAt),
//                                 ),
//                               ),
//                             ),
//                           )
//                           .toList(),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//working ends

// lib/screens/payment_screen.dart
import 'package:classroom_frontend/PaymentRow_model.dart';
import 'package:classroom_frontend/offering_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_service.dart';

// ✅ Conditional import: web gets JS bridge, mobile gets a stub (no dart:js in this file)
import 'package:classroom_frontend/payments/web_js_stub.dart'
    if (dart.library.js) 'package:classroom_frontend/payments/web_js_real.dart'
    as webpay;

// ✅ Mobile plugin for Android/iOS
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final String mobile;
  final String email;
  const PaymentScreen({super.key, required this.mobile, required this.email});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Future<Map<String, dynamic>> _future;
  late Future<List<Offering>> _offeringsFuture;

  // Razorpay (mobile)
  Razorpay? _rzp;

  @override
  void initState() {
    super.initState();
    _future = ApiService.fetchMyBillingRaw(widget.mobile);
    _offeringsFuture = ApiService.fetchOfferings(mobile: widget.mobile);

    // Initialize mobile Razorpay only for Android/iOS
    if (!kIsWeb) {
      _rzp = Razorpay();
      _rzp!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onMobilePaymentSuccess);
      _rzp!.on(Razorpay.EVENT_PAYMENT_ERROR, _onMobilePaymentError);
      _rzp!.on(Razorpay.EVENT_EXTERNAL_WALLET, _onMobileExternalWallet);
    }
  }

  @override
  void dispose() {
    // Cleanup Razorpay (mobile)
    _rzp?.clear();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _future = ApiService.fetchMyBillingRaw(widget.mobile);
      _offeringsFuture = ApiService.fetchOfferings(mobile: widget.mobile);
    });
  }

  String _money(int paise) => '₹ ${(paise / 100).toStringAsFixed(2)}';

  Widget _subjectBreakdown(dynamic bySubjectRaw) {
    final items = (bySubjectRaw as List?)?.cast<dynamic>() ?? [];
    if (items.isEmpty) {
      return const Card(child: ListTile(title: Text('No pending lectures')));
    }
    String money(int p) => '₹ ${(p / 100).toStringAsFixed(2)}';
    return Column(
      children: items.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        final title = '${m['subjectname']} • ${m['teacher_mobile']}';
        final sub =
            'Lectures: ${m['count']} • Rate: ${money((m['rate_paise'] as num).toInt())}';
        final trailing = money((m['amount_paise'] as num).toInt());
        return Card(
          child: ListTile(
            leading: const Icon(Icons.book),
            title: Text(title),
            subtitle: Text(sub),
            trailing: Text(trailing),
          ),
        );
      }).toList(),
    );
  }

  /// Unified payment entry—works on Web + Android + iOS
  Future<void> _payNow() async {
    try {
      // 1) Create order on your backend
      final order = await ApiService.createOrderPerLecture(
        mobile: widget.mobile,
      );

      final orderId = (order['order_id'] ?? '').toString();
      final keyId = (order['key'] ?? '').toString();
      final amount = (order['amount'] as num?)?.toInt() ?? 0; // paise
      final currency = (order['currency'] ?? 'INR').toString();

      if (orderId.isEmpty || keyId.isEmpty || amount <= 0) {
        throw Exception('Bad order payload: $order');
      }

      // 2) Build common checkout options
      final options = {
        'key': keyId,
        'amount': amount, // in paise
        'currency': currency,
        'name': 'Online Classes',
        'description': 'Per-lecture billing',
        'order_id': orderId,
        'prefill': {
          'contact': widget.mobile,
          'email': widget.email.isNotEmpty
              ? widget.email
              : 'noreply@example.com',
        },
        'theme': {'color': '#13A0A4'},
      };

      if (kIsWeb) {
        // 3A) WEB flow (JS bridge)
        webpay.openRazorpay(
          options,
          onSuccess: (resp) async {
            try {
              final paymentId = (resp['razorpay_payment_id'] ?? '').toString();
              final signature = (resp['razorpay_signature'] ?? '').toString();
              await ApiService.confirmPayment(
                mobile: widget.mobile,
                orderId: orderId,
                paymentId: paymentId,
                signature: signature,
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment successful!')),
              );
              _reload();
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Confirm failed: $e')));
            }
          },
          onError: (_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment cancelled/failed')),
            );
          },
        );
      } else {
        // 3B) ANDROID / iOS flow (mobile plugin)
        _mobileOpenCheckout(options);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
    }
  }

  // ===== Mobile (Android/iOS) handlers =====

  void _mobileOpenCheckout(Map<String, dynamic> options) {
    try {
      _rzp?.open(options);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to start payment: $e')));
    }
  }

  Future<void> _onMobilePaymentSuccess(PaymentSuccessResponse resp) async {
    try {
      // orderId was set in options; razorpay returns paymentId + signature
      final paymentId = resp.paymentId ?? '';
      final orderId = resp.orderId ?? '';
      final signature = resp.signature ?? '';

      await ApiService.confirmPayment(
        mobile: widget.mobile,
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment successful!')));
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Confirm failed: $e')));
    }
  }

  void _onMobilePaymentError(PaymentFailureResponse resp) {
    final code = resp.code;
    final message = resp.message ?? 'Unknown error';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Payment failed ($code): $message')));
  }

  void _onMobileExternalWallet(ExternalWalletResponse resp) {
    // Optional: handle external wallet if you enable them
    final wallet = resp.walletName ?? 'wallet';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet selected: $wallet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Payments'),
              backgroundColor: const Color(0xFF13A0A4),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText('Error: ${snap.error}'),
            ),
          );
        }

        final data = snap.data ?? const {};
        final pendingDyn = data['pending'];
        if (pendingDyn is! Map) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Payments'),
              backgroundColor: const Color(0xFF13A0A4),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Unexpected server response for "pending": ${pendingDyn.runtimeType}',
              ),
            ),
          );
        }
        final pending = Map<String, dynamic>.from(pendingDyn);
        final totalLectures = (pending['total_lectures'] as num? ?? 0).toInt();
        final amountPaise = (pending['amount_paise'] as num? ?? 0).toInt();

        final bySubjectList = (pending['by_subject'] as List?) ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Payments'),
            backgroundColor: const Color(0xFF13A0A4),
            actions: [
              IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF13A0A4), Color(0xFF3CCACA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    title: Text('Pending: $totalLectures lecture(s)'),
                    subtitle: Text('Amount due: ${_money(amountPaise)}'),
                    trailing: ElevatedButton(
                      onPressed: totalLectures > 0 ? _payNow : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEE4C82),
                      ),
                      child: const Text('Pay Now'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Breakdown by Subject (Pending)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _subjectBreakdown(bySubjectList),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                const Text(
                  'Available Subjects (All)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                FutureBuilder<List<Offering>>(
                  future: _offeringsFuture,
                  builder: (_, subsnap) {
                    if (subsnap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (subsnap.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Failed to load subjects: ${subsnap.error}',
                        ),
                      );
                    }
                    final offerings = subsnap.data ?? const [];
                    if (offerings.isEmpty) {
                      return const Card(
                        child: ListTile(title: Text('No subjects created yet')),
                      );
                    }
                    String money0(int p) => '₹ ${(p / 100).toStringAsFixed(0)}';

                    return Column(
                      children: offerings.map((o) {
                        final isEnrolled = o.enrolled;
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.menu_book),
                            title: Text(o.subjectname),
                            subtitle: Text(
                              'Teacher: ${o.teacherMobile} • Rate: ${money0(o.pricePaise)}',
                            ),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                try {
                                  if (isEnrolled) {
                                    await ApiService.unenrollSubject(
                                      mobile: widget.mobile,
                                      subjectId: o.id,
                                    );
                                  } else {
                                    await ApiService.enrollSubject(
                                      mobile: widget.mobile,
                                      subjectId: o.id,
                                    );
                                  }
                                  _reload();
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Action failed: $e'),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isEnrolled
                                    ? Colors.red
                                    : Colors.green,
                              ),
                              child: Text(isEnrolled ? 'Unenroll' : 'Enroll'),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                const Text(
                  'Payment History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Builder(
                  builder: (_) {
                    final historyListDyn = data['history'];
                    final history = <PaymentRow>[];
                    if (historyListDyn is List) {
                      for (final h in historyListDyn) {
                        if (h is Map<String, dynamic>) {
                          history.add(PaymentRow.fromJson(h));
                        }
                      }
                    }
                    if (history.isEmpty) {
                      return const Card(
                        child: ListTile(title: Text('No payments yet')),
                      );
                    }
                    return Column(
                      children: history
                          .map(
                            (p) => Card(
                              child: ListTile(
                                leading: const Icon(Icons.receipt_long),
                                title: Text(
                                  '${p.status.toUpperCase()} • ${_money(p.amount)}',
                                ),
                                subtitle: Text(
                                  DateFormat(
                                    'd MMM yyyy, hh:mm a',
                                  ).format(p.createdAt),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
