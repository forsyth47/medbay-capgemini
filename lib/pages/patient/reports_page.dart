import '../../widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String period = 'Weekly';

  Map<String, dynamic> get _data {
    switch (period) {
      case 'Daily':
        return {
          'adherence': '75%',
          'missed': '1',
          'onTime': '75%',
          'taken': 3,
          'total': 4,
          'pie': [3, 1, 0],
          'line': [FlSpot(0, 1), FlSpot(1, 1), FlSpot(2, 0), FlSpot(3, 1)],
          'lineLabels': ['Morn', 'Aft', 'Eve', 'Night'],
          'bar': [1.0, 1.0, 0.0, 1.0],
        };
      case 'Monthly':
        return {
          'adherence': '90%',
          'missed': '8',
          'onTime': '90%',
          'taken': 108,
          'total': 120,
          'pie': [108, 8, 4],
          'line': [FlSpot(0, 26), FlSpot(1, 28), FlSpot(2, 27), FlSpot(3, 27)],
          'lineLabels': ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4'],
          'bar': [26.0, 28.0, 27.0, 27.0],
        };
      case 'Weekly':
      default:
        return {
          'adherence': '89%',
          'missed': '2',
          'onTime': '89%',
          'taken': 25,
          'total': 28,
          'pie': [25, 2, 1],
          'line': [
            FlSpot(0, 4), FlSpot(1, 3), FlSpot(2, 4), FlSpot(3, 4),
            FlSpot(4, 3), FlSpot(5, 4), FlSpot(6, 3)
          ],
          'lineLabels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          'bar': [4.0, 3.0, 4.0, 4.0, 3.0, 4.0, 3.0],
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    final pieColors = [Colors.green.shade400, Colors.red.shade400, Colors.blue.shade200];
    final pieTitles = ['Taken', 'Missed', 'Upcoming'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Track your medication adherence', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: ['Daily', 'Weekly', 'Monthly'].map((p) {
                  final active = p == period;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => period = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: active ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          p,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: active ? Colors.blue.shade700 : Colors.white70,
                            fontWeight: active ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Stats
            Row(
              children: [
                _statBox(d['adherence'], 'Adherence', Colors.green),
                const SizedBox(width: 12),
                _statBox(d['missed'], 'Missed', Colors.red),
                const SizedBox(width: 12),
                _statBox(d['onTime'], 'On Time', Colors.blue),
              ],
            ),
            const SizedBox(height: 20),

            // Line chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$period Trend', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, meta) {
                                final labels = d['lineLabels'] as List<String>;
                                if (v.toInt() >= 0 && v.toInt() < labels.length) {
                                  return Text(labels[v.toInt()],
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 10));
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: d['line'] as List<FlSpot>,
                            isCurved: true,
                            color: Colors.blue.shade700,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.shade700.withValues(alpha: 0.1),
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

            // Pie + Bar
            Row(
              children: [
                // Donut PieChart
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecor,
                    child: Column(
                      children: [
                        const Text('Breakdown', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 140,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 36,
                              centerSpaceColor: Colors.grey.shade50,
                              sections: [
                                for (int i = 0; i < 3; i++)
                                  PieChartSectionData(
                                    value: (d['pie'] as List<int>)[i].toDouble(),
                                    color: pieColors[i],
                                    radius: 24,
                                    title: '${(d['pie'] as List<int>)[i]}',
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: [
                            for (int i = 0; i < 3; i++)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(color: pieColors[i], shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(pieTitles[i], style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Bar chart
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          period == 'Daily' ? 'Today' : period == 'Weekly' ? 'This Week' : 'This Month',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 140,
                          child: BarChart(
                            BarChartData(
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              barGroups: [
                                for (int i = 0; i < (d['bar'] as List<double>).length; i++)
                                  BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: (d['bar'] as List<double>)[i],
                                        color: Colors.blue.shade700,
                                        width: 10,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: _cardDecor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'You took ${d['taken']} out of ${d['total']} doses this ${period.toLowerCase()}. '
                    '${d['missed'] == '0' ? 'Perfect adherence!' : 'Keep improving your consistency.'}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: _cardDecor,
        child: Column(
          children: [
            Text(val, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
