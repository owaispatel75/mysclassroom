// Model (reuse the same shape used in student list)
class TeacherSession {
  final int id;
  final String subject;
  final DateTime startAt;
  final DateTime endAt;
  final int durationMins;
  final String status; // scheduled | live | ended

  TeacherSession({
    required this.id,
    required this.subject,
    required this.startAt,
    required this.endAt,
    required this.durationMins,
    required this.status,
  });

  factory TeacherSession.fromJson(Map<String, dynamic> j) {
    return TeacherSession(
      id: j['id'] as int,
      subject: j['subject'] as String,
      startAt: DateTime.parse(j['start_at'] as String),
      endAt: DateTime.parse(j['end_at'] as String),
      durationMins: (j['duration_mins'] ?? 0) as int,
      status: (j['status'] ?? 'scheduled') as String,
    );
  }
}
