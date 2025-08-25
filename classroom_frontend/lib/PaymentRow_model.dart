// class PaymentRow {
//   final int id;
//   final String mobile;
//   final int amount; // paise
//   final String currency;
//   final String status;
//   final DateTime createdAt;
//   final DateTime? paidAt;

//   PaymentRow.fromJson(Map<String, dynamic> j)
//     : id = j['id'],
//       mobile = j['mobile'],
//       amount = j['amount'],
//       currency = j['currency'],
//       status = j['status'],
//       createdAt = DateTime.parse(j['created_at']),
//       paidAt = j['paid_at'] != null ? DateTime.parse(j['paid_at']) : null;
// }

class PaymentRow {
  final int id;
  final String mobile;
  final int amount; // paise
  final String currency;
  final String status;
  final DateTime createdAt;
  final DateTime? paidAt;

  PaymentRow({
    required this.id,
    required this.mobile,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.paidAt,
  });

  factory PaymentRow.fromJson(Map<String, dynamic> j) {
    return PaymentRow(
      id: (j['id'] as num).toInt(),
      mobile: (j['mobile'] ?? '').toString(),
      amount: (j['amount'] as num).toInt(),
      currency: (j['currency'] ?? 'INR').toString(),
      status: (j['status'] ?? '').toString(),
      createdAt: DateTime.parse(j['created_at'].toString()),
      paidAt: j['paid_at'] == null
          ? null
          : DateTime.parse(j['paid_at'].toString()),
    );
  }
}

