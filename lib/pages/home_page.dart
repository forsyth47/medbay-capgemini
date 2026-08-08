import 'dart:async';
import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../models/schedule.dart';
import '../models/alert.dart';
import '../services/supabase_service.dart';
import '../widgets/app_bottom_nav.dart';
import 'medicines_page.dart';
import 'reports_page.dart';
import 'alerts_page.dart';
import 'profile_page.dart';
import 'load_dispenser_page.dart';
import 'set_medicine_time_page.dart';
import 'ai_prescription_scanner_page.dart'; // NEW

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Medicine> medicines = [];
  List<Schedule> schedules = [];
  List<Alert> alerts = [];
  bool loading = true;

  Timer? _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final m = await SupabaseService.getMedicines();
    final a = await SupabaseService.getAlerts();
    final s = await SupabaseService.getSchedules();
    setState(() {
      medicines = m;
      schedules = s;
      alerts = a.where((x) => x.isToday).take(2).toList();
      loading = false;
    });
    _startCountdown();
  }

  // Parse "08:00 AM" → TimeOfDay
  TimeOfDay? _parseTime(String t) {
    try {
      final parts = t.split(' ');
      if (parts.length != 2) return null;
      final hm = parts[0].split(':');
      if (hm.length != 2) return null;
      var hour = int.parse(hm[0]);
      final minute = int.parse(hm[1]);
      if (parts[1] == 'PM' && hour != 12) hour += 12;
      if (parts[1] == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  void _updateCountdown() {
    final now = DateTime.now();
    DateTime? nextTime;

    for (final sch in schedules) {
      final tod = _parseTime(sch.time);
      if (tod == null) continue;
      var target = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
      if (target.isBefore(now)) {
        target = target.add(const Duration(days: 1));
      }
      if (nextTime == null || target.isBefore(nextTime)) {
        nextTime = target;
      }
    }

    if (nextTime != null && mounted) {
      setState(() => _timeRemaining = nextTime!.difference(now));
    }
  }

  String get _countdownText {
    final h = _timeRemaining.inHours.toString().padLeft(2, '0');
    final m = (_timeRemaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_timeRemaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // Demo schedule display: name, slot, time, isTaken
  final List<(String, String, String, bool)> _todaySchedule = const [
    ('Metformin 500mg', 'Slot 1', '8:00 AM', true),
    ('Atorvastatin 10mg', 'Slot 2', '1:00 PM', false),
    ('Amlodipine 5mg', 'Slot 3', '8:00 PM', false),
    ('Pantoprazole 40mg', 'Slot 4', '10:30 PM', false),
  ];

  void _onNavTap(int index) {
    if (index == 0) return;
    final pages = [
      const MedicinesPage(),
      const ReportsPage(),
      const AlertsPage(),
      const ProfilePage(),
    ];
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => pages[index - 1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Today's doses: 3 taken out of 4 total
    const int takenDoses = 3;
    final int totalDoses = medicines.isNotEmpty ? medicines.length : 4;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // Blue header
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade700, Colors.blue.shade500],
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
                                  const Text('Rahul Sharma 👋',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.settings_outlined,
                                        color: Colors.white),
                                    onPressed: () {},
                                  ),
                                  CircleAvatar(
                                    backgroundColor: Colors.white24,
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _statChip('Today\'s Doses', '$takenDoses/$totalDoses'),
                              _statChip('Adherence', '94%'),
                              _statChip('Streak', '12 days'),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Next Medication Card with LIVE countdown
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('NEXT MEDICATION',
                                        style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 10)),
                                    Text('Time Remaining',
                                        style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 10)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            schedules.isNotEmpty
                                                ? medicines.first.name
                                                : 'Pantoprazole 40mg',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            schedules.isNotEmpty
                                                ? 'Slot ${schedules.first.slotNumber} · Next dose'
                                                : 'Slot 4 · After Dinner · 1 Tablet',
                                            style: TextStyle(
                                                color: Colors.grey.shade400,
                                                fontSize: 12)),
                                      ],
                                    ),
                                    Text(
                                      _countdownText,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontFeatures: [
                                            FontFeature.tabularFigures()
                                          ]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: 0.37,
                                    backgroundColor: Colors.grey.shade700,
                                    valueColor: AlwaysStoppedAnimation(
                                        Colors.blue.shade400),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('37% elapsed',
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 10)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('Quick Actions',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 2.2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            children: [
                              _quickAction(
                                'Load\nDispenser',
                                Icons.inventory_2_outlined,
                                Colors.blue,
                                () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const LoadDispenserPage())),
                              ),
                              _quickAction(
                                'Set Medicine\nTime',
                                Icons.access_time,
                                Colors.orange,
                                () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const SetMedicineTimePage())),
                              ),
                              // REPLACED: Medicine Slots → AI Prescription Scanner
                              _quickAction(
                                'AI Prescription\nScanner',
                                Icons.document_scanner,
                                Colors.green,
                                () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const AIPrescriptionScannerPage())),
                              ),
                              _quickAction(
                                'Generate\nReport',
                                Icons.bar_chart,
                                Colors.purple,
                                () => _onNavTap(2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Today\'s Schedule',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                              // FIX: View All now goes to Medicines page
                              TextButton(
                                onPressed: () => _onNavTap(1),
                                child: const Text('See All >'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // FIX: explicit schedule list with correct times & statuses
                          ..._todaySchedule.map((s) => _scheduleItem(s.$1, s.$2, s.$3, s.$4)),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Device Status',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                              TextButton(
                                onPressed: () {},
                                child: const Text('Details >'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _deviceCard(),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Recent Alerts',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                              TextButton(
                                onPressed: () => _onNavTap(3),
                                child: const Text('See All >'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...alerts.take(2).map((a) => _alertItem(a)),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _quickAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // FIX: accepts explicit time & taken status instead of deriving from medicine stock
  Widget _scheduleItem(String name, String slot, String time, bool isTaken) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.medication,
              color: isTaken ? Colors.green : Colors.blue.shade300),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(slot,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Text(time,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(width: 8),
          Text(
            isTaken ? 'Taken' : 'Upcoming',
            style: TextStyle(
              color: isTaken ? Colors.green : Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deviceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.settings_suggest, color: Colors.blue.shade400),
                  const SizedBox(width: 8),
                  const Text('ESP32 Dispenser',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('87%',
                      style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _deviceStat('RTC', 'OK', Colors.green),
              _deviceStat('Servo', 'OK', Colors.green),
              _deviceStat('Temp', '36°C', Colors.green),
              _deviceStat('Sync', '2m ago', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _deviceStat(String label, String val, Color c) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        const SizedBox(height: 4),
        Text(val,
            style: TextStyle(
                color: c, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _alertItem(Alert a) {
    Color iconColor = Colors.blue;
    IconData icon = Icons.info;
    if (a.type == 'success') {
      iconColor = Colors.green;
      icon = Icons.check_circle;
    } else if (a.type == 'warning') {
      iconColor = Colors.orange;
      icon = Icons.warning;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(a.message,
                style: const TextStyle(fontSize: 13)),
          ),
          Text(
            '${a.createdAt.hour}:${a.createdAt.minute.toString().padLeft(2, '0')}',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
