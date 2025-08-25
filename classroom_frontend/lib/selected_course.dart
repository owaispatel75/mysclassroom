import 'package:shared_preferences/shared_preferences.dart';

class SelectedCourse {
  final String subjectname;
  final String teacherMobile;

  const SelectedCourse({
    required this.subjectname,
    required this.teacherMobile,
  });

  static const _kSubject = 'selected_subjectname';
  static const _kTeacher = 'selected_teacher_mobile';

  static Future<void> save(String subjectname, String teacherMobile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSubject, subjectname);
    await prefs.setString(_kTeacher, teacherMobile);
  }

  static Future<SelectedCourse?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kSubject);
    final t = prefs.getString(_kTeacher);
    if (s == null || t == null) return null;
    return SelectedCourse(subjectname: s, teacherMobile: t);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSubject);
    await prefs.remove(_kTeacher);
  }
}
