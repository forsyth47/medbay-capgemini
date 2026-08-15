import 'package:Medbay/widgets/doctor_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'doctor_home_page.dart';
import 'doctor_patients_page.dart';
import 'doctor_reports_page.dart';
import 'doctor_profile_page.dart';

class DoctorAlertsPage extends StatefulWidget {
  const DoctorAlertsPage({super.key});

  @override
  State<DoctorAlertsPage> createState() => _DoctorAlertsPageState();
}

class _DoctorAlertsPageState extends State<DoctorAlertsPage> {
  Color get _primary => const Color(0xFF0D9488);

  final List<_AlertItem> _alerts = [
    _AlertItem('Repeated Missed Doses', 'Vijay has missed 2 doses of Amlodipine in the last 24 hours.', 'urgent', Colors.red),
    _AlertItem('Low Medication Stock', 'Anita Patel: Slot 3 has only 4 tablets remaining.', 'normal', Colors.orange),
    _AlertItem('Device Offline', 'Meera Joshi\'s dispenser has been offline for 3 hours.', 'urgent', Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('3 alerts require attention',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _alerts.length,
        itemBuilder: (_, i) => _alertCard(_alerts[i]),
      ),
      bottomNavigationBar: const DoctorBottomNav(currentIndex: 3),
    );
  }

  Widget _alertCard(_AlertItem a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: a.color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: a.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(a.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              if (a.severity == 'urgent')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Urgent',
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(a.desc,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              _actionBtn('View Patient', a.color, () {}),
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _AlertItem {
  final String title;
  final String desc;
  final String severity;
  final Color color;
  _AlertItem(this.title, this.desc, this.severity, this.color);
}
