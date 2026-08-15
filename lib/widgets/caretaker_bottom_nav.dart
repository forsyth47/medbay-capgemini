import 'package:flutter/material.dart';
import '../pages/caretaker/caretaker_home_page.dart';
import '../pages/caretaker/caretaker_patients_page.dart';
import '../pages/caretaker/caretaker_alerts_page.dart';
import '../pages/caretaker/caretaker_profile_page.dart';

class CaretakerBottomNav extends StatelessWidget {
  final int currentIndex;
  const CaretakerBottomNav({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;
    final pages = [
      const CaretakerHomePage(),
      const CaretakerPatientsPage(),
      const CaretakerAlertsPage(),
      const CaretakerProfilePage(),
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
      selectedItemColor: const Color(0xFF7C3AED),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Patients'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
