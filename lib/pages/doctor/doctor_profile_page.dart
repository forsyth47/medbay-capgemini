import 'package:Medbay/widgets/doctor_bottom_nav.dart';
import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import 'doctor_home_page.dart';
import 'doctor_patients_page.dart';
import 'doctor_reports_page.dart';
import 'doctor_alerts_page.dart';
import '../login_page.dart';

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key});

  Color get _primary => const Color(0xFF0D9488);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 0,
        title: const Text('Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: _primary.withOpacity(0.1),
                    child: Icon(Icons.person, size: 32, color: _primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dr. Rajesh Sharma',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Cardiologist · Apollo Hospital',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('24 patients assigned',
                            style: TextStyle(
                                color: _primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Professional Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Professional Info',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  _infoRow('Specialization', 'Cardiology'),
                  _infoRow('Hospital', 'Apollo Hospital, Mumbai'),
                  _infoRow('Experience', '18 years'),
                  _infoRow('License', 'MCI-2006-42187'),
                  _infoRow('Email', 'doctor@medidisp.demo'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await SupabaseService.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const DoctorBottomNav(currentIndex: 4),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
