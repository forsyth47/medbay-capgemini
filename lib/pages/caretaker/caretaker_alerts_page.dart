import 'package:flutter/material.dart';
import 'caretaker_home_page.dart';
import 'caretaker_patients_page.dart';
import 'caretaker_profile_page.dart';

class CaretakerAlertsPage extends StatefulWidget {
  const CaretakerAlertsPage({super.key});

  @override
  State<CaretakerAlertsPage> createState() => _CaretakerAlertsPageState();
}

class _CaretakerAlertsPageState extends State<CaretakerAlertsPage> {
  Color get _primary => const Color(0xFF7C3AED);

  final List<_AlertItem> _alerts = [
    _AlertItem('Missed Dose', 'Vijay Kumar missed Amlodipine at 6:00 PM.', 'urgent', Colors.red),
    _AlertItem('Low Stock Warning', 'Slot 4 (Metformin) critically low — 10% remaining.', 'normal', Colors.orange),
    _AlertItem('Dose Completed', 'Ravi Singh took all 3 medications today.', 'normal', Colors.green),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('3 alerts need attention',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _alerts.length,
        itemBuilder: (_, i) => _alertCard(_alerts[i]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (idx) {
          if (idx == 2) return;
          final pages = [
            const CaretakerHomePage(),
            const CaretakerPatientsPage(),
            const CaretakerProfilePage(),
          ];
          final routeIdx = idx > 2 ? idx - 3 : idx;
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => pages[routeIdx]));
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline), label: 'Patients'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined), label: 'Alerts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
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
            ],
          ),
          const SizedBox(height: 6),
          Text(a.desc,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              _btn('View Patient', a.color, () {}),
              const SizedBox(width: 8),
              _btn('Acknowledge', Colors.grey.shade600, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn(String text, Color color, VoidCallback onTap) {
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
