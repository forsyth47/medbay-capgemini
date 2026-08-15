import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/splash_page.dart';
import 'pages/patient/home_page.dart';
import 'pages/doctor/doctor_home_page.dart';
import 'pages/caretaker/caretaker_home_page.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://lcxwceloeobohyowdykz.supabase.co',
    publishableKey: 'sb_publishable_XNZGlgVH7f83R54gs484FQ_1mJZch5s',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediDispenser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Roboto',
      ),
      home: const SplashPage(),
    );
  }
}

/// Call this after login to route to the correct home based on role
Future<void> navigateToRoleHome(BuildContext context) async {
  final profile = await SupabaseService.getProfile();
  if (profile == null) return;

  final page = profile.isDoctor
      ? const DoctorHomePage()
      : profile.isCaretaker
          ? const CaretakerHomePage()
          : const HomePage(); // existing patient home

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => page),
    (route) => false,
  );
}
