// class Offering {
//   final int id;
//   final String subject;
//   final String teacherMobile;
//   final int pricePaise;
//   final String currency;

//   Offering.fromJson(Map<String, dynamic> j)
//     : id = j['id'],
//       subject = j['subject'],
//       teacherMobile = j['teacher_mobile'],
//       pricePaise = j['price_paise'],
//       currency = j['currency'];
// }

// class Offering {
//   final int id;
//   final String subject; // maps from subjectname
//   final String teacherMobile; // maps from teacher_mobile
//   final int pricePaise; // per-lecture rate (paise)
//   final String currency;
//   final bool active;

//   Offering({
//     required this.id,
//     required this.subject,
//     required this.teacherMobile,
//     required this.pricePaise,
//     required this.currency,
//     required this.active,
//   });

//   factory Offering.fromJson(Map<String, dynamic> j) {
//     return Offering(
//       id: (j['id'] as num?)?.toInt() ?? 0,
//       subject: (j['subjectname'] ?? '') as String,
//       teacherMobile: (j['teacher_mobile'] ?? '') as String,
//       pricePaise: (j['price_paise'] as num?)?.toInt() ?? 0,
//       currency: (j['currency'] ?? 'INR') as String,
//       active: (j['active'] as bool?) ?? true,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'subjectname': subject,
//     'teacher_mobile': teacherMobile,
//     'price_paise': pricePaise,
//     'currency': currency,
//     'active': active,
//   };

//   Offering copyWith({
//     int? id,
//     String? subject,
//     String? teacherMobile,
//     int? pricePaise,
//     String? currency,
//     bool? active,
//   }) {
//     return Offering(
//       id: id ?? this.id,
//       subject: subject ?? this.subject,
//       teacherMobile: teacherMobile ?? this.teacherMobile,
//       pricePaise: pricePaise ?? this.pricePaise,
//       currency: currency ?? this.currency,
//       active: active ?? this.active,
//     );
//   }
// }

//working starts

// class Offering {
//   final int id;
//   //final String subject; // from subjectname
//   final String subjectname;
//   final String teacherMobile; // from teacher_mobile
//   final int pricePaise;
//   final String currency;
//   final bool active;

//   Offering({
//     required this.id,
//     // required this.subject,
//     required this.subjectname,
//     required this.teacherMobile,
//     required this.pricePaise,
//     required this.currency,
//     required this.active,
//   });

//   static bool _toBool(dynamic v) {
//     if (v is bool) return v;
//     if (v is num) return v != 0; // handles 1/0, tinyint
//     if (v is String) {
//       final s = v.toLowerCase();
//       return s == 'true' || s == '1' || s == 'yes';
//     }
//     return true; // sensible default
//   }

//   String get displayLabel =>
//       '$subjectname — ${teacherMobile.isEmpty ? "—" : teacherMobile}';

//   factory Offering.fromJson(Map<String, dynamic> j) {
//     return Offering(
//       id: (j['id'] as num?)?.toInt() ?? 0,
//       subjectname: (j['subjectname'] ?? '') as String,
//       teacherMobile: (j['teacher_mobile'] ?? '') as String,
//       pricePaise: (j['price_paise'] as num?)?.toInt() ?? 0,
//       currency: (j['currency'] ?? 'INR') as String,
//       active: _toBool(j['active']),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'subjectname': subjectname,
//     'teacher_mobile': teacherMobile,
//     'price_paise': pricePaise,
//     'currency': currency,
//     'active': active,
//   };

//   Offering copyWith({
//     int? id,
//     String? subjectname,
//     String? teacherMobile,
//     int? pricePaise,
//     String? currency,
//     bool? active,
//   }) {
//     return Offering(
//       id: id ?? this.id,
//       subjectname: subjectname ?? this.subjectname,
//       teacherMobile: teacherMobile ?? this.teacherMobile,
//       pricePaise: pricePaise ?? this.pricePaise,
//       currency: currency ?? this.currency,
//       active: active ?? this.active,
//     );
//   }
// }

class Offering {
  final int id;
  final String subjectname; // from backend key `subjectname`
  final String teacherMobile; // from backend key `teacher_mobile`
  final int pricePaise;
  final String currency;
  final bool active;
  final bool enrolled;

  Offering({
    required this.id,
    required this.subjectname,
    required this.teacherMobile,
    required this.pricePaise,
    required this.currency,
    required this.active,
    this.enrolled = false,
  });

  // static bool _toBool(dynamic v) {
  //   if (v is bool) return v;
  //   if (v is num) return v != 0; // supports tinyint 0/1
  //   if (v is String) {
  //     final s = v.toLowerCase();
  //     return s == 'true' || s == '1' || s == 'yes';
  //   }
  //   return true; // sensible default
  // }

  static bool _toBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }
    return false;
  }

  factory Offering.fromJson(Map<String, dynamic> j) => Offering(
    id: (j['id'] as num?)?.toInt() ?? 0,
    subjectname: (j['subjectname'] ?? '') as String,
    teacherMobile: (j['teacher_mobile'] ?? '') as String,
    pricePaise: (j['price_paise'] as num?)?.toInt() ?? 0,
    currency: (j['currency'] ?? 'INR') as String,
    active: _toBool(j['active']),
    enrolled: _toBool(j['enrolled']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'subjectname': subjectname,
    'teacher_mobile': teacherMobile,
    'price_paise': pricePaise,
    'currency': currency,
    'active': active,
    'enrolled': enrolled,
  };

  String get displayLabel =>
      '$subjectname — ${teacherMobile.isEmpty ? "—" : teacherMobile}';

  Offering copyWith({
    int? id,
    String? subjectname,
    String? teacherMobile,
    int? pricePaise,
    String? currency,
    bool? active,
  }) {
    return Offering(
      id: id ?? this.id,
      subjectname: subjectname ?? this.subjectname,
      teacherMobile: teacherMobile ?? this.teacherMobile,
      pricePaise: pricePaise ?? this.pricePaise,
      currency: currency ?? this.currency,
      active: active ?? this.active,
    );
  }
}
