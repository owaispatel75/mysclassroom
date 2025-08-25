class TeacherUser {
  final String fullname;
  final String mobile;
  TeacherUser({required this.fullname, required this.mobile});

  factory TeacherUser.fromJson(Map<String, dynamic> j) => TeacherUser(
    fullname: j['fullname'] as String,
    mobile: j['mobile'] as String,
  );

  @override
  String toString() => '$fullname ($mobile)';
}