import 'package:flutter/material.dart';

class CaretakerPatientDetailPage extends StatelessWidget {
  final String patientId;
  final String patientName;
  const CaretakerPatientDetailPage(
      {super.key, required this.patientId, required this.patientName});

  Color get _primary => const Color(0xFF7C3AED);

  final List<_TodayMed> _meds = const [
    _TodayMed('Vitamin D 500mg', '8:00 AM', true),
    _TodayMed('Paracetamol', '1:00 PM', true),
    _TodayMed('Amlodipine 5mg', '6:00 PM', false),
    _TodayMed('Metformin', '10:00 PM', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(patientName,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('Patient · 54 yrs',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Missed dose banner
            Container(
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
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Text('Missed Dose Alert',
                          style: TextStyle(
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Amlodipine · 6:00 PM — Not dispensed',
                      style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _btn('Call Patient', Colors.red.shade600, () {}),
                      const SizedBox(width: 8),
                      _btn('Acknowledge', Colors.red.shade400, () {}),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("Today's Medication",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._meds.map((m) => _medRow(m)),
            const SizedBox(height: 20),
            const Text('Dispenser Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _dispenserCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _medRow(_TodayMed m) {
    Color statusColor = m.taken ? Colors.green : Colors.red;
    String status = m.taken ? 'Taken' : 'Missed';
    if (!m.taken && m.time == '10:00 PM') {
      statusColor = Colors.blue;
      status = 'Upcoming';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(m.time,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(m.name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Text(status,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _dispenserCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DispenserStat('Connection', 'Online', Colors.green),
              _DispenserStat('Battery', '82%', Colors.teal),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DispenserStat('Wi-Fi', 'Strong', Colors.green),
              _DispenserStat('Last Sync', '5m ago', Colors.indigo),
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

class _TodayMed {
  final String name;
  final String time;
  final bool taken;
  const _TodayMed(this.name, this.time, this.taken);
}

class _DispenserStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _DispenserStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
