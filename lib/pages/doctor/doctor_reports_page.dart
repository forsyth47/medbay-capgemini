import '../../widgets/doctor_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DoctorReportsPage extends StatefulWidget {
  const DoctorReportsPage({super.key});

  @override
  State<DoctorReportsPage> createState() => _DoctorReportsPageState();
}

class _DoctorReportsPageState extends State<DoctorReportsPage> {
  Color get _primary => const Color(0xFF0D9488);

    final List<_PatientAdherence> _patients = const [
    _PatientAdherence('Anita Patel', 0.95),
    _PatientAdherence('Meera Joshi', 0.88),
    _PatientAdherence('Vijay Kumar', 0.82),
    _PatientAdherence('Ravi Singh', 0.71),
  ];

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
            Text('Analytics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Patient adherence overview',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top stats
            Row(
              children: [
                _statBox('4', 'Total Patients', _primary),
                const SizedBox(width: 12),
                _statBox('84%', 'Avg. Adherence', Colors.teal),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statBox('1', 'Critical Cases', Colors.red),
                const SizedBox(width: 12),
                _statBox('6', 'Missed This Week', Colors.orange),
              ],
            ),
            const SizedBox(height: 20),

            // Patient adherence ranking
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Patient Adherence Ranking',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._patients.map((p) => _adherenceBar(p)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Weekly trend
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Weekly Trend',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                if (v.toInt() < days.length) {
                                  return Text(days[v.toInt()],
                                      style: TextStyle(
                                          color: Colors.grey.shade500, fontSize: 10));
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 80),
                              FlSpot(1, 83),
                              FlSpot(2, 81),
                              FlSpot(3, 85),
                              FlSpot(4, 84),
                              FlSpot(5, 87),
                              FlSpot(6, 84),
                            ],
                            isCurved: true,
                            color: _primary,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: _primary.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Alert breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alert Distribution',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: [
                          PieChartSectionData(
                            value: 6, color: Colors.red.shade400, radius: 22,
                            title: '6', titleStyle: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          PieChartSectionData(
                            value: 4, color: Colors.orange.shade400, radius: 22,
                            title: '4', titleStyle: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          PieChartSectionData(
                            value: 18, color: _primary, radius: 22,
                            title: '18', titleStyle: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 16,
                    children: [
                      _legend('Urgent', Colors.red.shade400),
                      _legend('Low Stock', Colors.orange.shade400),
                      _legend('Normal', _primary),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Critical patients
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Critical Patients',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _criticalTile('Ravi Singh', 'Adherence dropped to 71%', Colors.orange),
                  const SizedBox(height: 8),
                  _criticalTile('Meera Joshi', 'Device offline · 3h', Colors.red),                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const DoctorBottomNav(currentIndex: 2),
    );
  }

  BoxDecoration get _cardDecor => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  Widget _statBox(String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: _cardDecor,
        child: Column(
          children: [
            Text(val,
                style: TextStyle(
                    color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _adherenceBar(_PatientAdherence p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(p.name, style: const TextStyle(fontSize: 12)),
              Text('${(p.score * 100).toInt()}%',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: p.score,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                p.score > 0.8 ? _primary : p.score > 0.6 ? Colors.orange : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _criticalTile(String name, String issue, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(issue,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientAdherence {
  final String name;
  final double score;
  const _PatientAdherence(this.name, this.score);
}
