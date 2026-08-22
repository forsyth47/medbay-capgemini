import 'package:flutter/material.dart';
import '../../models/alert.dart';
import '../../services/supabase_service.dart';
import '../../widgets/caretaker_bottom_nav.dart';

class CaretakerAlertsPage extends StatefulWidget {
  const CaretakerAlertsPage({super.key});

  @override
  State<CaretakerAlertsPage> createState() => _CaretakerAlertsPageState();
}

class _CaretakerAlertsPageState extends State<CaretakerAlertsPage> {
  Color get _primary => const Color(0xFF7C3AED);
  List<Alert> alerts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = SupabaseService.currentUserId!;
    final profile = await SupabaseService.getProfile();
    final data = await SupabaseService.getAlertsForStakeholder(uid, profile?.role ?? 'caretaker');
    setState(() {
      alerts = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${alerts.length} alerts need attention',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : alerts.isEmpty
              ? const Center(child: Text('No alerts'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: alerts.length,
                  itemBuilder: (_, i) => _alertCard(alerts[i]),
                ),
      bottomNavigationBar: const CaretakerBottomNav(currentIndex: 2),
    );
  }

  Widget _alertCard(Alert a) {
    // Request alerts shown as status chips to stakeholders
    if (a.type == 'request') {
      Color chipColor = Colors.blue;
      String chipText = 'Pending';
      if (a.requestStatus == 'accepted') {
        chipColor = Colors.green;
        chipText = 'Accepted';
      } else if (a.requestStatus == 'rejected') {
        chipColor = Colors.red;
        chipText = 'Rejected';
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: chipColor, width: 4)),
        ),
        child: Row(
          children: [
            Icon(Icons.medical_services, color: chipColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(a.message,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: chipColor.withValues(alpha: 0.3)),
              ),
              child: Text(chipText,
                  style: TextStyle(
                      color: chipColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    // Normal alerts (keep existing styling)
    Color color = Colors.blue;
    if (a.type == 'missed' || a.type == 'offline') color = Colors.red;
    if (a.type == 'low_stock') color = Colors.orange;
    if (a.type == 'success') color = Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(a.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(a.message,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              _actionBtn('View Patient', color, () {}),
              const SizedBox(width: 8),
              _actionBtn('Contact Caretaker', Colors.grey.shade600, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
