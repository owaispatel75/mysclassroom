class AppUser {
  final int id;
  final String fullname;
  final String mobile;
  final String email;
  final String role; // 'student' | 'teacher'
  final bool active;

  AppUser({
    required this.id,
    required this.fullname,
    required this.mobile,
    required this.email,
    required this.role,
    required this.active,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: (j['id'] as num).toInt(),
    fullname: (j['fullname'] ?? '') as String,
    mobile: (j['mobile'] ?? '') as String,
    email: (j['email'] ?? '') as String,
    role: (j['role'] ?? 'student') as String,
    active: (j['active'] ?? true) is bool
        ? j['active'] as bool
        : ((j['active'] ?? 1) == 1),
  );
}
