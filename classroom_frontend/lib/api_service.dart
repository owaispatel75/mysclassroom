import 'dart:convert';
import 'package:classroom_frontend/BillingSummary_model.dart';
import 'package:classroom_frontend/MySubscription_model.dart';
import 'package:classroom_frontend/TeacherSession_model.dart';
import 'package:classroom_frontend/TeacherUser_model.dart';
import 'package:classroom_frontend/TodaySession_model.dart';
import 'package:classroom_frontend/offering_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// class ApiService {
//   // Use 10.0.2.2 if you run on Android emulator; use 127.0.0.1 for Chrome
//   static const String base = 'http://127.0.0.1:8000/api';

//   // static Future<void> sendOtp(String mobile) async {
//   //   final res = await http.post(
//   //     Uri.parse('$base/send-otp'),
//   //     headers: {'Content-Type': 'application/json'},
//   //     body: jsonEncode({'mobile': mobile}),
//   //   );

//   //   // debug prints
//   //   debugPrint('POST $base -> ${res.statusCode}');
//   //   debugPrint('Body: ${res.body}');
//   //   if (res.statusCode != 200) {
//   //     throw Exception('Failed to request OTP');
//   //   }
//   // }

//   static const _timeout = Duration(seconds: 3);

//   static Future<void> sendOtp(String mobile) async {
//     final url = Uri.parse('$base/send-otp');
//     final res = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'mobile': mobile}),
//     );
//     debugPrint('POST $url -> ${res.statusCode}');
//     debugPrint('Body: ${res.body}');
//     if (res.statusCode != 200) {
//       throw Exception(
//         'Failed to request OTP. Code: ${res.statusCode}, Body: ${res.body}',
//       );
//     }
//   }

//   // static Future<String?> fetchOtp(String mobile) async {
//   //   final res = await http.get(Uri.parse('$base/fetch-otp?mobile=$mobile'));
//   //   if (res.statusCode == 200) {
//   //     final data = jsonDecode(res.body);
//   //     return data['otp']?.toString();
//   //   }
//   //   return null;
//   // }

//   static Future<String?> fetchOtp(String mobile) async {
//     final url = Uri.parse('$base/fetch-otp?mobile=$mobile');
//     final res = await http.get(url).timeout(_timeout);
//     if (res.statusCode == 200) {
//       final data = jsonDecode(res.body);
//       return (data['otp'] ?? '').toString();
//     }
//     return null;
//   }

//   static Future<Map<String, dynamic>> verifyOtp(
//     String mobile,
//     String otp,
//   ) async {
//     final res = await http.post(
//       Uri.parse('$base/verify-otp'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'mobile': mobile, 'otp': otp}),
//     );

//     if (res.statusCode == 200) {
//       return jsonDecode(res.body)['user'];
//     } else {
//       throw Exception(jsonDecode(res.body)['message'] ?? 'Verification failed');
//     }
//   }
// }

class ApiService {
  // static const String base = 'http://192.168.29.211:8000';
  //static const String base = 'http://127.0.0.1:8000/api';
  static const String base = 'https://classroom.auxcgen.com/api';

  static Map<String, String> get _jsonHeaders => const {
    'Accept': 'application/json', // <— force JSON, not HTML
  };

  static Map<String, String> _jsonPostHeaders() => const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static Future<Map<String, dynamic>> fetchMyBillingRaw(String mobile) async {
    final uri = Uri.parse('$base/payments/me?mobile=$mobile');
    final res = await http.get(uri, headers: _jsonHeaders).timeout(_timeout);

    if (res.statusCode != 200) {
      // Many dev 500s return HTML. Surface a clean error.
      final contentType = res.headers['content-type'] ?? '';
      if (contentType.contains('application/json')) {
        throw Exception('Billing failed: ${res.statusCode} ${res.body}');
      } else {
        throw Exception(
          'Billing failed: ${res.statusCode} (non-JSON)\n${res.body}',
        );
      }
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map) {
      throw Exception(
        'Unexpected billing payload (expected Map, got ${decoded.runtimeType})',
      );
    }
    return Map<String, dynamic>.from(decoded);
  }

  // api_service.dart (add helpers)

  static String _ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  static Future<List<TodaySession>> fetchTodaySessionsForStudentOnDay(
    String mobile, {
    required DateTime day,
  }) async {
    final uri = Uri.parse(
      '$base/classrooms/today',
    ).replace(queryParameters: {'mobile': mobile, 'date': _ymd(day)});
    final r = await http.get(uri, headers: {'Accept': 'application/json'});
    if (r.statusCode != 200)
      throw Exception('Failed: ${r.statusCode} ${r.body}');
    final list = (jsonDecode(r.body)['sessions'] as List).cast<dynamic>();
    return list
        .map((e) => TodaySession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<TodaySession>> fetchTeacherOnDay({
    required String teacherMobile,
    required DateTime day,
  }) async {
    final uri = Uri.parse(
      '$base/classrooms/teacher/today',
    ).replace(queryParameters: {'mobile': teacherMobile, 'date': _ymd(day)});
    final r = await http.get(uri, headers: {'Accept': 'application/json'});
    if (r.statusCode != 200)
      throw Exception('Failed: ${r.statusCode} ${r.body}');
    final list = (jsonDecode(r.body)['sessions'] as List).cast<dynamic>();
    return list
        .map((e) => TodaySession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Map<String, dynamic>> createOrderPerLecture({
    required String mobile,
  }) async {
    final res = await http
        .post(
          Uri.parse('$base/payments/create-order'),
          headers: _jsonPostHeaders(),
          body: jsonEncode({'mobile': mobile}),
        )
        .timeout(_timeout);

    if (res.statusCode != 200) {
      final ct = res.headers['content-type'] ?? '';
      if (ct.contains('application/json')) {
        throw Exception('Create order failed: ${res.statusCode} ${res.body}');
      } else {
        throw Exception(
          'Create order failed: ${res.statusCode} (non-JSON)\n${res.body}',
        );
      }
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map) {
      throw Exception(
        'Unexpected order payload (expected Map, got ${decoded.runtimeType})',
      );
    }
    return Map<String, dynamic>.from(decoded);
  }

  static Future<void> confirmPayment({
    required String mobile,
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final res = await http
        .post(
          Uri.parse('$base/payments/confirm'),
          headers: _jsonPostHeaders(),
          body: jsonEncode({
            'mobile': mobile,
            'order_id': orderId,
            'payment_id': paymentId,
            'signature': signature,
          }),
        )
        .timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception('Confirm failed: ${res.statusCode} ${res.body}');
    }
  }

  static Future<void> sendOtp(String mobile, String deviceId) async {
    final res = await http.post(
      Uri.parse('$base/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile': mobile, 'device_id': deviceId}),
    );
    if (res.statusCode == 423) {
      throw Exception('ALREADY_LOGGED');
    }
    if (res.statusCode != 200) {
      throw Exception('Failed: ${res.statusCode} ${res.body}');
    }
  }

  static const _timeout = Duration(seconds: 3);

  static Future<String?> fetchOtp(String mobile) async {
    final url = Uri.parse('$base/fetch-otp?mobile=$mobile');
    final res = await http.get(url).timeout(_timeout);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['otp'] ?? '').toString();
    }
    return null;
  }

  static Future<void> logoutAll(String mobile) async {
    final res = await http.post(
      Uri.parse('$base/logout-all'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile': mobile}),
    );
    if (res.statusCode != 200) {
      throw Exception('Logout-all failed');
    }
  }

  static Future<void> logout(String mobile, String deviceId) async {
    final res = await http.post(
      Uri.parse('$base/logout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile': mobile, 'device_id': deviceId}),
    );
    if (res.statusCode != 200) {
      throw Exception('Logout failed: ${res.statusCode} ${res.body}');
    }
  }

  static Future<void> updateProfile({
    required String mobile, // immutable key on server
    required String fullname,
    required String email, // can be empty string
  }) async {
    final res = await http.post(
      Uri.parse('$base/profile/update'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'mobile': mobile,
        'fullname': fullname,
        'email': email,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('Update failed: ${res.statusCode} ${res.body}');
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
    String mobile,
    String otp,
    String deviceId,
  ) async {
    final res = await http.post(
      Uri.parse('$base/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile': mobile, 'otp': otp, 'device_id': deviceId}),
    );
    if (res.statusCode == 423) throw Exception('ALREADY_LOGGED');
    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['message'] ?? 'Verification failed');
    }
    return jsonDecode(res.body)['user'];
  }

  static Future<List<TodaySession>> fetchTodaySessions({
    int? classroomId,
  }) async {
    final uri = classroomId == null
        ? Uri.parse('$base/classrooms/today')
        : Uri.parse('$base/classrooms/today?classroomid=$classroomId');

    final res = await http.get(uri, headers: {'Accept': 'application/json'});

    if (res.statusCode != 200) {
      throw Exception('Failed to load sessions: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['sessions'] as List).cast<dynamic>();
    return list
        .map((e) => TodaySession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // static Future<List<TodaySession>> fetchTeacherToday({
  //   required String teacherMobile,
  // }) async {
  //   final uri = Uri.parse(
  //     '$base/classrooms/teacher/today?mobile=$teacherMobile',
  //   );
  //   final res = await http.get(uri, headers: {'Accept': 'application/json'});
  //   if (res.statusCode != 200) {
  //     throw Exception('Failed to load: ${res.statusCode} ${res.body}');
  //   }
  //   final data = jsonDecode(res.body) as Map<String, dynamic>;
  //   final list = (data['sessions'] as List).cast<dynamic>();
  //   return list
  //       .map((e) => TodaySession.fromJson(e as Map<String, dynamic>))
  //       .toList();
  // }

  static Future<void> startClass(int id) async {
    final res = await http.post(
      Uri.parse('$base/classrooms/$id/start'),
      headers: {'Accept': 'application/json'},
    );
    if (res.statusCode != 200) {
      throw Exception('Start failed: ${res.statusCode} ${res.body}');
    }
  }

  static Future<void> endClass(int id) async {
    final res = await http.post(
      Uri.parse('$base/classrooms/$id/end'),
      headers: {'Accept': 'application/json'},
    );
    if (res.statusCode != 200) {
      throw Exception('End failed: ${res.statusCode} ${res.body}');
    }
  }

  // -------- Admin Classroom CRUD --------
  static Future<List<TodaySession>> adminFetchSubjects(DateTime day) async {
    final d = DateFormat('yyyy-MM-dd').format(day);
    final uri = Uri.parse('$base/classrooms/subjects?date=$d');
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('Load failed: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['sessions'] as List).cast<dynamic>();
    return list
        .map((e) => TodaySession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<int> adminCreateSubject({
    String? classroomId,
    String? classroomName,
    String? teacherMobile,
    required String subject,
    required DateTime startAt,
    required int durationMins,
    String status = 'scheduled',
  }) async {
    final res = await http.post(
      Uri.parse('$base/classrooms/subjects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'classroomid': classroomId,
        'classroomname': classroomName,
        'teacher_mobile': teacherMobile,
        'subject': subject,
        'start_at': startAt.toIso8601String(),
        'duration_mins': durationMins,
        'status': status,
      }),
    );
    if (res.statusCode != 201) {
      throw Exception('Create failed: ${res.statusCode} ${res.body}');
    }
    return (jsonDecode(res.body)['id'] as num).toInt();
  }

  static Future<void> adminUpdateSubject({
    required int id,
    String? classroomId,
    String? classroomName,
    String? teacherMobile,
    String? subject,
    DateTime? startAt,
    int? durationMins,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (classroomId != null) body['classroomid'] = classroomId;
    if (classroomName != null) body['classroomname'] = classroomName;
    if (teacherMobile != null) body['teacher_mobile'] = teacherMobile;
    if (subject != null) body['subject'] = subject;
    if (startAt != null) body['start_at'] = startAt.toIso8601String();
    if (durationMins != null) body['duration_mins'] = durationMins;
    if (status != null) body['status'] = status;

    final res = await http.put(
      Uri.parse('$base/classrooms/subjects/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception('Update failed: ${res.statusCode} ${res.body}');
    }
  }

  static Future<void> adminDeleteSubject(int id) async {
    final res = await http.delete(Uri.parse('$base/classrooms/subjects/$id'));
    if (res.statusCode != 200) {
      throw Exception('Delete failed: ${res.statusCode} ${res.body}');
    }
  }

  static Future<List<TodaySession>> fetchTodaySessionsForStudent(
    String mobile,
  ) async {
    final uri = Uri.parse('$base/classrooms/today?mobile=$mobile');
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('Failed: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['sessions'] as List).cast<dynamic>();
    return list
        .map((e) => TodaySession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> adminGrantTrialForOffering({
    required String mobile,
    required int offeringId,
    required int days,
  }) async {
    final r = await http.post(
      Uri.parse('$base/payments/trial'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile': mobile,
        'offering_id': offeringId,
        'days': days,
      }),
    );
    if (r.statusCode != 200) throw Exception(r.body);
  }

  static Future<List<TeacherUser>> fetchTeachers() async {
    final res = await http.get(
      Uri.parse('$base/teachers'),
      headers: {'Accept': 'application/json'},
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load teachers: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['teachers'] as List).cast<dynamic>();
    return list
        .map((e) => TeacherUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ApiService additions
  static Future<BillingSummary> fetchMyBilling(String mobile) async {
    final res = await http.get(Uri.parse('$base/payments/me?mobile=$mobile'));
    if (res.statusCode != 200) throw Exception(res.body);
    return BillingSummary.fromJson(jsonDecode(res.body));
  }

  static Future<Map<String, dynamic>> createOrder({
    required String mobile,
    required int amountPaise, // e.g., 49900 = ₹499
    String currency = 'INR',
  }) async {
    final res = await http.post(
      Uri.parse('$base/payments/create-order'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile': mobile,
        'amount': amountPaise,
        'currency': currency,
      }),
    );
    if (res.statusCode != 200) throw Exception(res.body);
    return jsonDecode(res.body);
  }

  // static Future<void> confirmPayment({
  //   required String mobile,
  //   required String orderId,
  //   required String paymentId,
  //   required String signature,
  // }) async {
  //   final res = await http.post(
  //     Uri.parse('$base/payments/confirm'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({
  //       'mobile': mobile,
  //       'order_id': orderId,
  //       'payment_id': paymentId,
  //       'signature': signature,
  //     }),
  //   );
  //   if (res.statusCode != 200) throw Exception(res.body);
  // }

  // Admin helpers
  static Future<void> adminGrantTrial(String mobile, int days) async {
    final r = await http.post(
      Uri.parse('$base/payments/trial'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile': mobile, 'days': days}),
    );
    if (r.statusCode != 200) throw Exception(r.body);
  }

  static Future<void> adminCreateManualPayment({
    required String mobile,
    required int amountPaise,
    String currency = 'INR',
  }) async {
    final r = await http.post(
      Uri.parse('$base/payments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile': mobile,
        'amount': amountPaise,
        'currency': currency,
      }),
    );
    if (r.statusCode != 201) throw Exception(r.body);
  }

  // static Future<List<Offering>> fetchOfferings({String? subject}) async {
  //   final uri = subject == null
  //       ? Uri.parse('$base/offerings')
  //       : Uri.parse('$base/offerings?subject=$subject');
  //   final r = await http.get(uri, headers: {'Accept': 'application/json'});
  //   if (r.statusCode != 200) throw Exception(r.body);
  //   final list = (jsonDecode(r.body)['offerings'] as List).cast<dynamic>();
  //   return list.map((e) => Offering.fromJson(e)).toList();
  // }

  // SUBJECTS (Offerings) CRUD
  // static Future<List<Offering>> fetchOfferings({String? subject}) async {
  //   final uri = subject == null
  //       ? Uri.parse('$base/offerings')
  //       : Uri.parse('$base/offerings?subject=$subject');
  //   final r = await http.get(uri, headers: {'Accept': 'application/json'});
  //   if (r.statusCode != 200) throw Exception(r.body);
  //   final list = (jsonDecode(r.body)['offerings'] as List).cast<dynamic>();
  //   return list
  //       .map((e) => Offering.fromJson(e as Map<String, dynamic>))
  //       .toList();
  // }

  static Future<List<Offering>> fetchOfferings({
    String? subject,
    String? mobile,
  }) async {
    final qp = <String, String>{};
    if (subject != null) qp['subject'] = subject;
    if (mobile != null) qp['mobile'] = mobile;

    final uri = Uri.parse(
      '$base/offerings',
    ).replace(queryParameters: qp.isEmpty ? null : qp);

    final r = await http.get(uri, headers: {'Accept': 'application/json'});
    if (r.statusCode != 200) throw Exception(r.body);
    final list = (jsonDecode(r.body)['offerings'] as List).cast<dynamic>();
    return list
        .map((e) => Offering.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> enrollSubject({
    required String mobile,
    required int subjectId,
  }) async {
    final r = await http.post(
      Uri.parse('$base/subscriptions/enroll'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'mobile': mobile, 'subject_id': subjectId}),
    );
    if (r.statusCode != 200) {
      throw Exception('Enroll failed: ${r.statusCode} ${r.body}');
    }
  }

  static Future<void> unenrollSubject({
    required String mobile,
    required int subjectId,
  }) async {
    final r = await http.post(
      Uri.parse('$base/subscriptions/unenroll'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'mobile': mobile, 'subject_id': subjectId}),
    );
    if (r.statusCode != 200) {
      throw Exception('Unenroll failed: ${r.statusCode} ${r.body}');
    }
  }

  // alias (used by AdminSubjectsScreen)
  static Future<List<Offering>> fetchAllSubjects() => fetchOfferings();

  static Future<void> createSubject({
    required String subjectname,
    required String teacherMobile,
    required int pricePaise, // rupees * 100
    String currency = 'INR',
    bool active = true,
  }) async {
    final r = await http.post(
      Uri.parse('$base/offerings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'subjectname': subjectname,
        'teacher_mobile': teacherMobile,
        'price_paise': pricePaise,
        'currency': currency,
        'active': active,
      }),
    );
    if (r.statusCode != 201) throw Exception(r.body);
  }

  static Future<void> updateSubject({
    required int id,
    required String subjectname,
    required String teacherMobile,
    required int pricePaise,
    String currency = 'INR',
    bool active = true,
  }) async {
    final r = await http.put(
      Uri.parse('$base/offerings/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'subjectname': subjectname,
        'teacher_mobile': teacherMobile,
        'price_paise': pricePaise,
        'currency': currency,
        'active': active,
      }),
    );
    if (r.statusCode != 200) throw Exception(r.body);
  }

  static Future<void> deleteSubject(int id) async {
    final r = await http.delete(Uri.parse('$base/offerings/$id'));
    if (r.statusCode != 200) throw Exception(r.body);
  }

  static Future<List<MySubscription>> fetchMySubscriptions(
    String mobile,
  ) async {
    final r = await http.get(
      Uri.parse('$base/subscriptions/me?mobile=$mobile'),
      headers: {'Accept': 'application/json'},
    );
    if (r.statusCode != 200) throw Exception(r.body);
    final list = (jsonDecode(r.body)['subscriptions'] as List).cast<dynamic>();
    return list.map((e) => MySubscription.fromJson(e)).toList();
  }

  // ApiService
  static Future<List<TodaySession>> fetchTodayAll() async {
    final uri = Uri.parse('$base/classrooms/today'); // no query
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('Failed: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['sessions'] as List).cast<dynamic>();
    return list
        .map((e) => TodaySession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<TodaySession>> fetchTeacherToday({
    required String teacherMobile,
  }) async {
    final uri = Uri.parse(
      '$base/classrooms/teacher/today?mobile=$teacherMobile&teacher_mobile=$teacherMobile',
    );
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('Failed to load: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['sessions'] as List).cast<dynamic>();
    return list
        .map((e) => TodaySession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // (optional) small normalizer so 091-999... == 999...
  static String normalizeMobile(String m) =>
      m.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^(0|91)'), '');

  // static Future<void> enrollSubject({
  //   required String mobile,
  //   required int subjectId, // offering id
  // }) async {
  //   final r = await http.post(
  //     Uri.parse('$base/subscriptions/enroll'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'mobile': mobile, 'subject_id': subjectId}),
  //   );
  //   if (r.statusCode != 200) {
  //     throw Exception('Enroll failed: ${r.statusCode} ${r.body}');
  //   }
  // }

  // static Future<void> unenrollSubject({
  //   required String mobile,
  //   required int subjectId, // offering id
  // }) async {
  //   final r = await http.post(
  //     Uri.parse('$base/subscriptions/unenroll'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'mobile': mobile, 'subject_id': subjectId}),
  //   );
  //   if (r.statusCode != 200) {
  //     throw Exception('Unenroll failed: ${r.statusCode} ${r.body}');
  //   }
  // }

  // -------- SUBJECTS (offerings) working starts --------

  // static Future<List<Offering>> fetchAllSubjects() async {
  //   final r = await http.get(
  //     Uri.parse('$base/offerings'),
  //     headers: {'Accept': 'application/json'},
  //   );
  //   if (r.statusCode != 200) throw Exception(r.body);
  //   final list = (jsonDecode(r.body)['offerings'] as List).cast<dynamic>();
  //   return list.map((e) => Offering.fromJson(e)).toList();
  // }

  // static Future<int> createSubject({
  //   required String subjectname,
  //   required String teacherMobile,
  //   required int pricePaise,
  //   String currency = 'INR',
  //   bool active = true,
  // }) async {
  //   final r = await http.post(
  //     Uri.parse('$base/offerings'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({
  //       'subjectname': subjectname,
  //       'teacher_mobile': teacherMobile,
  //       'price_paise': pricePaise,
  //       'currency': currency,
  //       'active': active,
  //     }),
  //   );
  //   if (r.statusCode != 201) throw Exception(r.body);
  //   return (jsonDecode(r.body)['id'] as num).toInt();
  // }

  // static Future<void> updateSubject({
  //   required int id,
  //   String? subjectname,
  //   String? teacherMobile,
  //   int? pricePaise,
  //   String? currency,
  //   bool? active,
  // }) async {
  //   final body = <String, dynamic>{};
  //   if (subjectname != null) body['subjectname'] = subjectname;
  //   if (teacherMobile != null) body['teacher_mobile'] = teacherMobile;
  //   if (pricePaise != null) body['price_paise'] = pricePaise;
  //   if (currency != null) body['currency'] = currency;
  //   if (active != null) body['active'] = active;

  //   final r = await http.put(
  //     Uri.parse('$base/offerings/$id'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(body),
  //   );
  //   if (r.statusCode != 200) throw Exception(r.body);
  // }

  // static Future<void> deleteSubject(int id) async {
  //   final r = await http.delete(Uri.parse('$base/offerings/$id'));
  //   if (r.statusCode != 200) throw Exception(r.body);
  // }

  // -------- SUBJECTS (offerings) working ends --------

  //old code

  // static Future<Map<String, dynamic>> fetchMyBillingRaw(String mobile) async {
  //   final uri = Uri.parse('$base/payments/me?mobile=$mobile');
  //   final res = await http.get(uri).timeout(_timeout);
  //   if (res.statusCode != 200) {
  //     throw Exception('Billing failed: ${res.statusCode} ${res.body}');
  //   }
  //   final decoded = jsonDecode(res.body);
  //   if (decoded is! Map) {
  //     // Make the error obvious in the UI instead of crashing in a cast later
  //     throw Exception(
  //       'Unexpected billing payload (expected Map, got ${decoded.runtimeType})',
  //     );
  //   }
  //   return Map<String, dynamic>.from(decoded);
  // }

  // static Future<Map<String, dynamic>> createOrderPerLecture({
  //   required String mobile,
  // }) async {
  //   final res = await http
  //       .post(
  //         Uri.parse('$base/payments/create-order'),
  //         headers: {'Content-Type': 'application/json'},
  //         body: jsonEncode({'mobile': mobile}),
  //       )
  //       .timeout(_timeout);

  //   if (res.statusCode != 200) {
  //     throw Exception('Create order failed: ${res.statusCode} ${res.body}');
  //   }
  //   final decoded = jsonDecode(res.body);
  //   if (decoded is! Map) {
  //     throw Exception(
  //       'Unexpected order payload (expected Map, got ${decoded.runtimeType})',
  //     );
  //   }
  //   return Map<String, dynamic>.from(decoded);
  // }

  // static Future<void> confirmPayment({
  //   required String mobile,
  //   required String orderId,
  //   required String paymentId,
  //   required String signature,
  // }) async {
  //   final res = await http
  //       .post(
  //         Uri.parse('$base/payments/confirm'),
  //         headers: {'Content-Type': 'application/json'},
  //         body: jsonEncode({
  //           'mobile': mobile,
  //           'order_id': orderId,
  //           'payment_id': paymentId,
  //           'signature': signature,
  //         }),
  //       )
  //       .timeout(_timeout);

  //   if (res.statusCode != 200) {
  //     throw Exception('Confirm failed: ${res.statusCode} ${res.body}');
  //   }
  // }

  // api_service.dart (add/replace these) (old codes)

  // static Future<Map<String, dynamic>> fetchMyBillingRaw(String mobile) async {
  //   final res = await http.get(Uri.parse('$base/payments/me?mobile=$mobile'));
  //   if (res.statusCode != 200) throw Exception(res.body);
  //   return jsonDecode(res.body) as Map<String, dynamic>;
  // }

  // static Future<Map<String, dynamic>> createOrderPerLecture({
  //   required String mobile,
  // }) async {
  //   final res = await http.post(
  //     Uri.parse('$base/payments/create-order'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'mobile': mobile}),
  //   );
  //   if (res.statusCode != 200) throw Exception(res.body);
  //   return jsonDecode(res.body) as Map<String, dynamic>;
  // }

  // static Future<void> confirmPayment({
  //   required String mobile,
  //   required String orderId,
  //   required String paymentId,
  //   required String signature,
  // }) async {
  //   final res = await http.post(
  //     Uri.parse('$base/payments/confirm'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({
  //       'mobile': mobile,
  //       'order_id': orderId,
  //       'payment_id': paymentId,
  //       'signature': signature,
  //     }),
  //   );
  //   if (res.statusCode != 200) throw Exception(res.body);
  // }

  static Future<void> markAttendance({
    required int sessionId,
    required String mobile,
  }) async {
    final res = await http.post(
      Uri.parse('$base/attendance/mark'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'session_id': sessionId, 'mobile': mobile}),
    );
    if (res.statusCode != 200) throw Exception(res.body);
  }

  // Reports
  static Future<Map<String, dynamic>> fetchAttendanceReport({
    required DateTime from,
    required DateTime to,
  }) async {
    final f = DateFormat('yyyy-MM-dd').format(from);
    final t = DateFormat('yyyy-MM-dd').format(to);
    final res = await http.get(
      Uri.parse('$base/reports/attendance?from=$f&to=$t'),
    );
    if (res.statusCode != 200) throw Exception(res.body);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> fetchRevenueReport({
    required DateTime from,
    required DateTime to,
  }) async {
    final f = DateFormat('yyyy-MM-dd').format(from);
    final t = DateFormat('yyyy-MM-dd').format(to);
    final res = await http.get(
      Uri.parse('$base/reports/revenue?from=$f&to=$t'),
    );
    if (res.statusCode != 200) throw Exception(res.body);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<void> attendanceStart({
    required int sessionId,
    required String mobile,
  }) async {
    final r = await http.post(
      Uri.parse('$base/attendance/start'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'session_id': sessionId, 'mobile': mobile}),
    );
    if (r.statusCode != 200) throw Exception(r.body);
  }

  static Future<void> attendanceStop({
    required int sessionId,
    required String mobile,
  }) async {
    final r = await http.post(
      Uri.parse('$base/attendance/stop'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'session_id': sessionId, 'mobile': mobile}),
    );
    if (r.statusCode != 200) throw Exception(r.body);
  }

  // NEW createOrder signature -> offering based
  static Future<Map<String, dynamic>> createOrderForOffering({
    required String mobile,
    required int offeringId,
  }) async {
    final r = await http.post(
      Uri.parse('$base/payments/create-order'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile': mobile, 'offering_id': offeringId}),
    );
    if (r.statusCode != 200) throw Exception(r.body);
    return jsonDecode(r.body);
  }
}
