import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/alert.dart';
import '../../services/supabase_service.dart';
import '../../widgets/doctor_bottom_nav.dart';
import 'doctor_patient_detail_page.dart';

class DoctorAlertsPage extends StatefulWidget {
  const DoctorAlertsPage({super.key});

  @override
  State<DoctorAlertsPage> createState() => _DoctorAlertsPageState();
}

class _DoctorAlertsPageState extends State<DoctorAlertsPage> {
  Color get _primary => const Color(0xFF0D9488);
  List<Alert> alerts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await SupabaseService.getUrgentAlerts(SupabaseService.currentUserId!);
    setState(() {
      alerts = data;
      loading = false;
    });
  }

  Future<void> _call(String? number) async {
    if (number == null || number.isEmpty) return;
    final uri = Uri.parse('tel:${number.replaceAll(RegExp(r'\s+'), '')}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _contactCaretaker(String patientId) async {
    final caretakers = await SupabaseService.getCaretakersForPatient(patientId);
    if (caretakers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No caretaker assigned')),
      );
      return;
    }
    await _showCaretakersDialog(caretakers);
  }

  Future<void> _showCaretakersDialog(List<Map<String, dynamic>> caretakers) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Contact Caretaker', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: caretakers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final c = caretakers[i];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: _primary.withValues(alpha: 0.1),
                  child: Icon(Icons.medical_services, color: _primary, size: 18),
                ),
                title: Text(c['full_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(c['mobile'] ?? '-', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                trailing: IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed: () => _call(c['mobile']),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _viewPatient(String patientId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorPatientDetailPage(
          patientId: patientId,
          patientName: 'Patient',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${alerts.length} urgent alerts',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : alerts.isEmpty
              ? const Center(child: Text('No urgent alerts'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: alerts.length,
                  itemBuilder: (_, i) => _alertCard(alerts[i]),
                ),
      bottomNavigationBar: const DoctorBottomNav(currentIndex: 3),
    );
  }

  Widget _alertCard(Alert a) {
    Color color = Colors.red;
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(a.severity!.toUpperCase(),
                    style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(a.message,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              _actionBtn('View Patient', color, () => _viewPatient(a.patientId ?? a.userId)),
              const SizedBox(width: 8),
              _actionBtn('Contact Caretaker', Colors.grey.shade600,
                  () => _contactCaretaker(a.patientId ?? a.userId)),
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
