import 'package:flutter/material.dart';
import '../pages/doctor/doctor_home_page.dart';
import '../pages/doctor/doctor_patients_page.dart';
import '../pages/doctor/doctor_reports_page.dart';
import '../pages/doctor/doctor_alerts_page.dart';
import '../pages/doctor/doctor_profile_page.dart';

class DoctorBottomNav extends StatelessWidget {
  final int currentIndex;
  const DoctorBottomNav({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;
    final pages = [
      const DoctorHomePage(),
      const DoctorPatientsPage(),
      const DoctorReportsPage(),
      const DoctorAlertsPage(),
      const DoctorProfilePage(),
    ];
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => pages[index],
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) => _navigate(context, i),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF0D9488),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Patients'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
