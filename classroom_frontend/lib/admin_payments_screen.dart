import 'package:classroom_frontend/offering_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:classroom_frontend/api_service.dart';
import 'package:classroom_frontend/BillingSummary_model.dart';
import 'package:classroom_frontend/PaymentRow_model.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  final _mobileCtrl = TextEditingController();
  Future<BillingSummary>? _future;

  @override
  void dispose() {
    _mobileCtrl.dispose();
    super.dispose();
  }

  // Future<void> _load() async {
  //   final m = _mobileCtrl.text.trim();
  //   if (m.isEmpty) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Enter a mobile number')));
  //     return;
  //   }
  //   final fut = ApiService.fetchMyBilling(m);
  //   setState(() {
  //     _future = fut;
  //     // _future = ApiService.fetchMyBilling(m);
  //   });
  // }

  void _load() {
    final m = _mobileCtrl.text.trim();
    if (m.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a mobile number')));
      return;
    }
    final fut = ApiService.fetchMyBilling(m); // start the future
    setState(() {
      _future = fut; // <-- purely synchronous assignment
    });
  }

  // Future<void> _grantTrial() async {
  //   final m = _mobileCtrl.text.trim();
  //   if (m.isEmpty) return;
  //   final daysCtrl = TextEditingController(text: '7');
  //   final ok = await showDialog<bool>(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text('Grant Trial'),
  //       content: TextField(
  //         controller: daysCtrl,
  //         keyboardType: TextInputType.number,
  //         decoration: const InputDecoration(
  //           labelText: 'Days',
  //           border: OutlineInputBorder(),
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           child: const Text('Grant'),
  //         ),
  //       ],
  //     ),
  //   );
  //   if (ok == true) {
  //     try {
  //       final days = int.tryParse(daysCtrl.text) ?? 0;
  //       if (days <= 0) throw Exception('Invalid days');
  //       await ApiService.adminGrantTrial(m, days);
  //       if (!mounted) return;
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Trial granted for $days day(s)')),
  //       );
  //       _load();
  //     } catch (e) {
  //       if (!mounted) return;
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Grant failed: $e')));
  //     }
  //   }
  // }

  Future<void> _grantTrial() async {
    final offers = await ApiService.fetchOfferings();
    Offering? selected;
    final daysCtrl = TextEditingController(text: '7');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Grant Trial'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Offering>(
              value: selected,
              decoration: const InputDecoration(labelText: 'Offering'),
              items: offers
                  .map(
                    (o) => DropdownMenuItem(
                      value: o,
                      child: Text('${o.subjectname} • ${o.teacherMobile}'),
                    ),
                  )
                  .toList(),
              onChanged: (v) => selected = v,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: daysCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Days',
                border: OutlineInputBorder(),
              ),
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
            child: const Text('Grant'),
          ),
        ],
      ),
    );

    if (ok == true && selected != null) {
      final m = _mobileCtrl.text.trim();
      final days = int.tryParse(daysCtrl.text) ?? 0;
      await ApiService.adminGrantTrialForOffering(
        mobile: m,
        offeringId: selected!.id,
        days: days,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Trial granted')));
      _load(); // refresh
    }
  }

  Future<void> _addManualPayment() async {
    final m = _mobileCtrl.text.trim();
    if (m.isEmpty) return;
    final amtCtrl = TextEditingController(text: '499');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Manual Payment'),
        content: TextField(
          controller: amtCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (₹)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        final rupees = int.tryParse(amtCtrl.text) ?? 0;
        if (rupees <= 0) throw Exception('Invalid amount');
        await ApiService.adminCreateManualPayment(
          mobile: m,
          amountPaise: rupees * 100,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Manual payment recorded')),
        );
        _load();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Add failed: $e')));
      }
    }
  }

  String _money(int paise) => '₹ ${(paise / 100).toStringAsFixed(2)}';

  String _when(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('d MMM yyyy, h:mm a').format(dt);
  }

  Color _chipColor(String s) {
    switch (s) {
      case 'trial':
        return Colors.orange;
      case 'active':
        return Colors.green;
      case 'expired':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments (Admin)'),
        backgroundColor: const Color(0xFF13A0A4),
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mobileCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Student mobile',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _load,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE4C82),
                  ),
                  child: const Text('Load'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_future == null)
              const Card(
                child: ListTile(title: Text('Enter a mobile and tap Load.')),
              )
            else
              FutureBuilder<BillingSummary>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snap.hasError) {
                    return Card(
                      child: ListTile(title: Text('Error: ${snap.error}')),
                    );
                  }
                  final s = snap.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: ListTile(
                          leading: Chip(
                            backgroundColor: _chipColor(s.status),
                            label: Text(
                              s.status.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            s.status == 'active'
                                ? 'Paid until: ${_when(s.paidUntil)}'
                                : s.status == 'trial'
                                ? 'Trial ends: ${_when(s.trialEndsAt)}'
                                : 'Plan expired',
                          ),
                          subtitle: const Text('Plan: Monthly'),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _grantTrial,
                              icon: const Icon(Icons.card_giftcard),
                              label: const Text('Grant Trial'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _addManualPayment,
                              icon: const Icon(Icons.add_task),
                              label: const Text('Add Manual Payment'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Payment History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (s.history.isEmpty)
                        const Card(
                          child: ListTile(title: Text('No payments yet')),
                        )
                      else
                        ...s.history.map(
                          (r) => Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.receipt_long,
                                color: r.status == 'paid'
                                    ? Colors.green
                                    : (r.status == 'failed'
                                          ? Colors.red
                                          : Colors.orange),
                              ),
                              title: Text(
                                '${_money(r.amount)} • ${r.currency}',
                              ),
                              subtitle: Text(
                                'Status: ${r.status}'
                                '\nCreated: ${_when(r.createdAt)}'
                                '${r.paidAt != null ? '\nPaid: ${_when(r.paidAt)}' : ''}',
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
