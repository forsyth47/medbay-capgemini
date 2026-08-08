import 'package:Medbay/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../services/supabase_service.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  List<Alert> alerts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await SupabaseService.getAlerts();
    setState(() {
      alerts = data;
      loading = false;
    });
  }

  (IconData, Color) _alertStyle(String type) {
    switch (type) {
      case 'success':
        return (Icons.check_circle, Colors.green);
      case 'reminder':
        return (Icons.notifications, Colors.blue);
      case 'missed':
        return (Icons.cancel, Colors.red);
      case 'offline':
        return (Icons.wifi_off, Colors.orange);
      case 'low_stock':
        return (Icons.warning, Colors.orange);
      default:
        return (Icons.info, Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = alerts.where((a) => a.isToday).toList();
    final yesterday = alerts.where((a) => a.isYesterday).toList();
    final older = alerts.where((a) => !a.isToday && !a.isYesterday).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Stay updated on your health',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (today.isNotEmpty) ...[
                  _sectionTitle('TODAY'),
                  ...today.map(_alertTile),
                ],
                if (yesterday.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _sectionTitle('YESTERDAY'),
                  ...yesterday.map(_alertTile),
                ],
                if (older.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _sectionTitle('2 DAYS AGO'),
                  ...older.map(_alertTile),
                ],
              ],
            ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _alertTile(Alert a) {
    final (icon, color) = _alertStyle(a.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(a.message,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${a.createdAt.hour}:${a.createdAt.minute.toString().padLeft(2, '0')}',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
