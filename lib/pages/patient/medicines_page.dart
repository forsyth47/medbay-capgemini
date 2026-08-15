// import 'package:Medbay/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import '../../models/medicine.dart';
import '../../services/supabase_service.dart';
import '../../widgets/app_bottom_nav.dart';

class MedicinesPage extends StatefulWidget {
  const MedicinesPage({super.key});

  @override
  State<MedicinesPage> createState() => _MedicinesPageState();
}

class _MedicinesPageState extends State<MedicinesPage> {
  List<Medicine> medicines = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await SupabaseService.getMedicines(SupabaseService.currentUserId!);
    setState(() {
      medicines = data;
      loading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Loaded':
        return Colors.green;
      case 'Low Stock':
        return Colors.orange;
      case 'Empty':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loaded = medicines.where((m) => m.status == 'Loaded').length;
    final low = medicines.where((m) => m.status == 'Low Stock').length;
    final empty = medicines.where((m) => m.status == 'Empty').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medicine Slots',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '4 slots available in your dispenser',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.blue.shade700,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      _summaryCard(loaded.toString(), 'Loaded', Colors.blue),
                      const SizedBox(width: 8),
                      _summaryCard(low.toString(), 'Low Stock', Colors.orange),
                      const SizedBox(width: 8),
                      _summaryCard(empty.toString(), 'Empty', Colors.red),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: medicines.length,
                    itemBuilder: (ctx, i) => _slotCard(medicines[i]),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _summaryCard(String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: TextStyle(
                color: color == Colors.blue ? Colors.white : color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color == Colors.blue ? Colors.white70 : color,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slotCard(Medicine m) {
    final color = _statusColor(m.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${m.slotNumber}',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${m.condition} · ${m.dosage}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                m.status,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${m.quantity} tablets remaining',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              if (m.status == 'Low Stock')
                Text(
                  'Refill soon',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: m.stockPercent,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                m.maxQuantity,
                (idx) => Container(
                  margin: const EdgeInsets.only(right: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: idx < m.quantity
                        ? color.withOpacity(0.8)
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
