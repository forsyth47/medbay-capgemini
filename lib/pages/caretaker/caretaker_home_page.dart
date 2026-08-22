import 'package:medbay/widgets/caretaker_bottom_nav.dart';
import 'package:flutter/material.dart';
import '../../models/patient_summary.dart';
import '../../services/supabase_service.dart';
import 'caretaker_patients_page.dart';
import 'caretaker_alerts_page.dart';
import 'caretaker_profile_page.dart';
import 'caretaker_patient_detail_page.dart';

class CaretakerHomePage extends StatefulWidget {
  const CaretakerHomePage({super.key});

  @override
  State<CaretakerHomePage> createState() => _CaretakerHomePageState();
}

class _CaretakerHomePageState extends State<CaretakerHomePage> {
  List<PatientSummary> patients = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = SupabaseService.currentUserId!;
    final data = await SupabaseService.getAssignedPatients('caretaker', uid);
    setState(() {
      patients = data;
      loading = false;
    });
  }

  Color get _primary => const Color(0xFF7C3AED); // violet-600

  void _nav(int idx) {
    final pages = [
      const CaretakerPatientsPage(),
      const CaretakerAlertsPage(),
      const CaretakerProfilePage(),
    ];
    if (idx == 0) return;
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => pages[idx - 1]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Purple header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primary, const Color(0xFFA78BFA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Good Morning,',
                                      style: TextStyle(color: Colors.white70)),
                                  const Text('Priya 👋',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('3 patients are under your care.',
                                      style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          fontSize: 12)),
                                ],
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _statCard('3', 'Patients'),
                              _statCard('2', 'Healthy'),
                              _statCard('1', 'Attention',
                                  accent: Colors.orange.shade300),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Patient Status
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Patient Status',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () => _nav(0),
                            child: const Text('All >'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...patients.take(2).map((p) => _patientTile(p)),
                    const SizedBox(height: 16),
                    // Missed Dose Alert
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _missedAlert(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const CaretakerBottomNav(currentIndex: 0),
    );
  }


  Widget _statCard(String val, String label, {Color? accent}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(val,
                style: TextStyle(
                    color: accent ?? Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _patientTile(PatientSummary p) {
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
        margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _primary.withValues(alpha: 0.1),
              child: Icon(Icons.person_outline, color: _primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
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
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Next: ${p.nextMedName} — ${p.nextMedTime}',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 11)),
                ],
              ),
            ),
            Text('${(p.adherence * 100).toInt()}% adh.',
                style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _missedAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade600),
              const SizedBox(width: 8),
              Text('Missed Dose Alert',
                  style: TextStyle(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
              'Vijay Kumar missed Amlodipine at 6:00 PM — not dispensed.',
              style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              _alertBtn('Call Patient', Colors.red.shade600, () {}),
              const SizedBox(width: 8),
              _alertBtn('Acknowledge', Colors.red.shade400, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _alertBtn(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
