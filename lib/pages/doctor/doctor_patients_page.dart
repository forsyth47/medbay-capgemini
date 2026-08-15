import 'package:flutter/material.dart';
import '../../models/patient_summary.dart';
import '../../services/supabase_service.dart';
import 'doctor_patient_detail_page.dart';
import 'doctor_home_page.dart';
import 'doctor_reports_page.dart';
import 'doctor_alerts_page.dart';
import 'doctor_profile_page.dart';

class DoctorPatientsPage extends StatefulWidget {
  const DoctorPatientsPage({super.key});

  @override
  State<DoctorPatientsPage> createState() => _DoctorPatientsPageState();
}

class _DoctorPatientsPageState extends State<DoctorPatientsPage> {
  List<PatientSummary> patients = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await SupabaseService.getAssignedPatients('doctor');
    setState(() {
      patients = data;
      loading = false;
    });
  }

  Color get _primary => const Color(0xFF0D9488);

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
            Text('Patients',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('24 patients under your care',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search patients...',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
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
            const DoctorHomePage(),
            const DoctorReportsPage(),
            const DoctorAlertsPage(),
            const DoctorProfilePage(),
          ];
          final routeIdx = idx > 1 ? idx - 2 : -1;
          if (routeIdx >= 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => pages[routeIdx]));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const DoctorHomePage()));
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline), label: 'Patients'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Reports'),
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
              builder: (_) => DoctorPatientDetailPage(
                  patientId: p.id, patientName: p.name))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: p.isOnline ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(p.isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 11)),
                      const SizedBox(width: 12),
                      Text('Last: ${p.lastActive ?? '-'}',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(p.status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 6),
                Text('${(p.adherence * 100).toInt()}%',
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
