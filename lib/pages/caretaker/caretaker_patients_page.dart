import 'package:flutter/material.dart';
import '../../models/patient_summary.dart';
import '../../services/supabase_service.dart';
import 'caretaker_home_page.dart';
import 'caretaker_alerts_page.dart';
import 'caretaker_profile_page.dart';
import 'caretaker_patient_detail_page.dart';

class CaretakerPatientsPage extends StatefulWidget {
  const CaretakerPatientsPage({super.key});

  @override
  State<CaretakerPatientsPage> createState() => _CaretakerPatientsPageState();
}

class _CaretakerPatientsPageState extends State<CaretakerPatientsPage> {
  List<PatientSummary> patients = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await SupabaseService.getAssignedPatients('caretaker');
    setState(() {
      patients = data;
      loading = false;
    });
  }

  Color get _primary => const Color(0xFF7C3AED);

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
            Text('My Patients',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('3 patients under care',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: patients.length,
              itemBuilder: (_, i) => _patientCard(patients[i]),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (idx) {
          if (idx == 1) return;
          final pages = [
            const CaretakerHomePage(),
            const CaretakerAlertsPage(),
            const CaretakerProfilePage(),
          ];
          final routeIdx = idx > 1 ? idx - 2 : idx;
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

  Widget _patientCard(PatientSummary p) {
    Color statusColor = Colors.green;
    if (p.status == 'Attention') statusColor = Colors.orange;
    if (p.status == 'Critical') statusColor = Colors.red;

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CaretakerPatientDetailPage(
                  patientId: p.id, patientName: p.name))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _primary.withOpacity(0.1),
                  child: Icon(Icons.person_outline, color: _primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${p.name}, ${p.age}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      Text('Next: ${p.nextMedName} ${p.nextMedTime}',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _miniStat('Adherence', '${(p.adherence * 100).toInt()}%',
                    statusColor),
                _miniStat('Device', p.deviceStatus ?? '-',
                    p.isOnline ? Colors.green : Colors.red),
                _miniStat('Stock', p.stockStatus ?? '-',
                    p.stockStatus == 'Low' ? Colors.orange : Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String val, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
        const SizedBox(height: 4),
        Text(val,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
