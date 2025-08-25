class TodaySession {
  final int id;
  final String subject;
  final DateTime startAt;
  final DateTime endAt;
  final int durationMins;
  final String status; // 'scheduled' | 'live'
  final bool joinable;
  
    // NEW (optional, present on admin list)
  final String? teacherMobile;
  final String? classroomName;

  TodaySession({
    required this.id,
    required this.subject,
    required this.startAt,
    required this.endAt,
    required this.durationMins,
    required this.status,
    required this.joinable,
    this.teacherMobile,
    this.classroomName,
  });

  factory TodaySession.fromJson(Map<String, dynamic> j) {
    return TodaySession(
      id: j['id'] as int,
      subject: j['subject'] as String,
      startAt: DateTime.parse(j['start_at'] as String),
      endAt: DateTime.parse(j['end_at'] as String),
      durationMins: (j['duration_mins'] ?? 0) as int,
      status: (j['status'] ?? 'scheduled') as String,
      joinable: (j['joinable'] ?? false) as bool,
      teacherMobile: j['teacher_mobile'] as String?, // <—
      classroomName: j['classroomname'] as String?, // <— if you include it
    );
  }
}