import 'package:classroom_frontend/PaymentRow_model.dart';

class BillingSummary {
  final String status; // trial|active|expired
  final DateTime? trialEndsAt;
  final DateTime? paidUntil;
  final List<PaymentRow> history;

  BillingSummary.fromJson(Map<String, dynamic> j)
    : status = j['status'],
      trialEndsAt = j['trial_ends_at'] != null
          ? DateTime.parse(j['trial_ends_at'])
          : null,
      paidUntil = j['paid_until'] != null
          ? DateTime.parse(j['paid_until'])
          : null,
      history = ((j['history'] as List?) ?? [])
          .map((e) => PaymentRow.fromJson(e))
          .toList();
}