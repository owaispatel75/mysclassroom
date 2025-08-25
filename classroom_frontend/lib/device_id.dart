// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';

// Future<String> getDeviceId() async {
//   final plugin = DeviceInfoPlugin();
//   if (Platform.isAndroid) {
//     final info = await plugin.androidInfo;
//     return info.id;
//   } else if (Platform.isIOS) {
//     final info = await plugin.iosInfo;
//     return info.identifierForVendor ?? 'ios-unknown';
//   }
//   return 'web-or-unknown';
// }

import 'dart:convert';
import 'dart:math';
import 'dart:io' show Platform; // safe to import; we'll guard with kIsWeb
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

const _kDeviceIdKey = 'device_id';

String _uuidV4() {
  final r = Random.secure();
  String hex(int len) =>
      List.generate(len, (_) => r.nextInt(16).toRadixString(16)).join();
  final s =
      '${hex(8)}-${hex(4)}-4${hex(3)}-${(8 + r.nextInt(4)).toRadixString(16)}${hex(3)}-${hex(12)}';
  return s;
}

/// Returns a stable, persisted deviceId for Android, iOS, and Web.
/// - Android: uses `androidInfo.id` (persists as fallback if null)
/// - iOS: uses `identifierForVendor` (persists as fallback if null/simulator)
/// - Web: hashes browser characteristics, persists the result
Future<String> getDeviceId() async {
  final prefs = await SharedPreferences.getInstance();

  // 1) return cached if present
  final cached = prefs.getString(_kDeviceIdKey);
  if (cached != null && cached.isNotEmpty) return cached;

  final plugin = DeviceInfoPlugin();
  String deviceId;

  // if (kIsWeb) {
  //   // WEB: create a fingerprint & hash it to get a compact stable id
  //   final w = await plugin.webBrowserInfo;
  //   final raw = [
  //     w.userAgent ?? '',
  //     w.vendor ?? '',
  //     w.hardwareConcurrency?.toString() ?? '',
  //     w.platform ?? '',
  //     w.language ?? '',
  //     (w.maxTouchPoints ?? 0).toString(),
  //   ].join('|');
  //   deviceId = 'web-${md5.convert(utf8.encode(raw)).toString()}';
  // } else if (Platform.isAndroid) {
  //   final a = await plugin.androidInfo;
  //   // `a.id` is stable per device (Android ID). Fallback to hash if missing.
  //   deviceId = a.id?.isNotEmpty == true
  //       ? 'and-${a.id}'
  //       : 'and-${md5.convert(utf8.encode('${a.brand}|${a.model}|${a.device}|${a.hardware}')).toString()}';
  // } else if (Platform.isIOS) {
  //   final i = await plugin.iosInfo;
  //   deviceId = (i.identifierForVendor?.isNotEmpty == true)
  //       ? 'ios-${i.identifierForVendor}'
  //       : 'ios-${md5.convert(utf8.encode('${i.name}|${i.model}|${i.systemName}|${i.systemVersion}')).toString()}';
  // } else {
  //   // Other platforms (desktop, etc.)
  //   final other = await plugin.deviceInfo;
  //   deviceId = 'oth-${md5.convert(utf8.encode(other.toString())).toString()}';
  // }

  if (kIsWeb) {
    // NEW: per-browser-instance UUID, persisted (incognito/profile ⇒ different)
    deviceId = 'web-${_uuidV4()}';
  } else if (Platform.isAndroid) {
    final a = await plugin.androidInfo;
    deviceId = a.id?.isNotEmpty == true ? 'and-${a.id}' : 'and-${_uuidV4()}';
  } else if (Platform.isIOS) {
    final i = await plugin.iosInfo;
    deviceId = (i.identifierForVendor?.isNotEmpty == true)
        ? 'ios-${i.identifierForVendor}'
        : 'ios-${_uuidV4()}';
  } else {
    deviceId = 'oth-${_uuidV4()}';
  }

  // 2) persist for stability across launches
  await prefs.setString(_kDeviceIdKey, deviceId);
  return deviceId;
}
