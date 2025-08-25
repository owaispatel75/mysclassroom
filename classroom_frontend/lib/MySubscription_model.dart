class MySubscription {
  final String subject;
  final String teacherMobile;
  final DateTime validFrom;
  final DateTime validTo;
  final String status; // trial|active

  MySubscription.fromJson(Map<String, dynamic> j)
    : subject = j['subject'],
      teacherMobile = j['teacher_mobile'] ?? '',
      validFrom = DateTime.parse(j['valid_from']),
      validTo = DateTime.parse(j['valid_to']),
      status = j['status'];
}