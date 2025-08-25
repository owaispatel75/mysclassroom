import 'package:classroom_frontend/api_service.dart';
import 'package:flutter/material.dart';

class InClassScreen extends StatelessWidget {
  final int sessionId;
  final String mobile;
  final String subject;
  const InClassScreen({
    super.key,
    required this.sessionId,
    required this.mobile,
    required this.subject,
  });

  Future<void> _leave(BuildContext context) async {
    try {
      await ApiService.attendanceStop(sessionId: sessionId, mobile: mobile);
    } catch (_) {}
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _leave(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(subject)),
        body: Center(
          child: ElevatedButton(
            onPressed: () => _leave(context),
            child: const Text('Leave class'),
          ),
        ),
      ),
    );
  }
}
