import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});
  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();
  late Future<Map<String, dynamic>> _attFuture;
  late Future<Map<String, dynamic>> _revFuture;

  @override
  void initState() {
    super.initState();
    _attFuture = ApiService.fetchAttendanceReport(from: _from, to: _to);
    _revFuture = ApiService.fetchRevenueReport(from: _from, to: _to);
  }

  void _reload() {
    setState(() {
      _attFuture = ApiService.fetchAttendanceReport(from: _from, to: _to);
      _revFuture = ApiService.fetchRevenueReport(from: _from, to: _to);
    });
  }

  Future<void> _pickRange() async {
    final from = await showDatePicker(
      context: context,
      initialDate: _from,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (from == null) return;
    final to = await showDatePicker(
      context: context,
      initialDate: _to,
      firstDate: from,
      lastDate: DateTime(2030),
    );
    if (to == null) return;
    setState(() {
      _from = from;
      _to = to;
    });
    _reload();
  }

  String _money(int paise) => '₹ ${(paise / 100).toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: const Color(0xFF13A0A4),
        actions: [
          IconButton(onPressed: _pickRange, icon: const Icon(Icons.event)),
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.people), text: 'Attendance'),
                Tab(icon: Icon(Icons.payments), text: 'Revenue'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Attendance
                  FutureBuilder<Map<String, dynamic>>(
                    future: _attFuture,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError)
                        return Center(child: Text('Error: ${snap.error}'));
                      final d = snap.data!;
                      final kpis = d['kpis'] as Map<String, dynamic>;
                      final byDay = (d['by_day'] as List).cast<dynamic>();
                      final bySub = (d['by_subject'] as List).cast<dynamic>();
                      final rows = (d['rows'] as List).cast<dynamic>();
                      return ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _KpiCard(
                                title: 'Attendances',
                                value: '${kpis['total_attendances']}',
                              ),
                              _KpiCard(
                                title: 'Active Students',
                                value: '${kpis['active_students']}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'By Day',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          _SimpleTable(
                            headers: const ['Day', 'Count'],
                            rows: [
                              for (final r in byDay) [r['day'], '${r['cnt']}'],
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'By Subject',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          _SimpleTable(
                            headers: const ['Subject', 'Count'],
                            rows: [
                              for (final r in bySub)
                                [r['subjectname'], '${r['cnt']}'],
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Raw rows',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          _SimpleTable(
                            headers: const [
                              'When',
                              'Student',
                              'Subject',
                              'Teacher',
                              'Session',
                            ],
                            rows: [
                              for (final r in rows)
                                [
                                  DateFormat(
                                    'yyyy-MM-dd HH:mm',
                                  ).format(DateTime.parse(r['attended_at'])),
                                  r['student_mobile'],
                                  r['subjectname'],
                                  r['teacher_mobile'] ?? '—',
                                  '${r['session_id']}',
                                ],
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  // Revenue
                  FutureBuilder<Map<String, dynamic>>(
                    future: _revFuture,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError)
                        return Center(child: Text('Error: ${snap.error}'));
                      final d = snap.data!;
                      final total = d['total_paise'] as int;
                      final byM = (d['by_month'] as List).cast<dynamic>();
                      final inv = (d['invoices'] as List).cast<dynamic>();
                      return ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          _KpiCard(
                            title: 'Total Revenue',
                            value: _money(total),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'By Month',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          _SimpleTable(
                            headers: const ['Month', 'Amount'],
                            rows: [
                              for (final r in byM)
                                [
                                  r['ym'],
                                  _money((r['sum_paise'] as num).toInt()),
                                ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Paid Invoices',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          _SimpleTable(
                            headers: const ['Paid At', 'Mobile', 'Amount'],
                            rows: [
                              for (final r in inv)
                                [
                                  DateFormat(
                                    'yyyy-MM-dd HH:mm',
                                  ).format(DateTime.parse(r['paid_at'])),
                                  r['mobile'],
                                  _money((r['amount'] as num).toInt()),
                                ],
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title, value;
  const _KpiCard({required this.title, required this.value});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

class _SimpleTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  const _SimpleTable({required this.headers, required this.rows});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [for (final h in headers) DataColumn(label: Text(h))],
          rows: [
            for (final r in rows)
              DataRow(cells: [for (final c in r) DataCell(Text(c))]),
          ],
        ),
      ),
    );
  }
}
