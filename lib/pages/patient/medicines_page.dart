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
  int slotCount = 0;
  bool loading = true;
  double stockPercent(int qty, int max) => max == 0 ? 0 : qty / max;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = SupabaseService.currentUserId!;
    final count = await SupabaseService.getSlotCount(uid);
    final data = await SupabaseService.getMedicines(uid);
    setState(() {
      slotCount = count;
      medicines = data;
      loading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Loaded': return Colors.green;
      case 'Low Stock': return Colors.orange;
      case 'Empty': return Colors.red;
      default: return Colors.grey;
    }
  }

  Medicine? _medForSlot(int slot) {
    try {
      return medicines.firstWhere((m) => m.slotNumber == slot);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loaded = medicines.where((m) => m.status == 'Loaded').length;
    final low = medicines.where((m) => m.status == 'Low Stock').length;
    final empty = slotCount - medicines.length + medicines.where((m) => m.status == 'Empty').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Medicine Slots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('$slotCount slots available in your dispenser', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
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
                    itemCount: slotCount,
                    itemBuilder: (ctx, i) => _slotCard(i + 1),
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
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(color: color == Colors.blue ? Colors.white : color, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color == Colors.blue ? Colors.white70 : color, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _slotCard(int slotNum) {
    final m = _medForSlot(slotNum);
    final color = m != null ? _statusColor(m.status) : Colors.grey;
    final qty = m?.quantity ?? 0;
    final max = m?.maxQuantity ?? 25;

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
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('$slotNum', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m?.name ?? 'Empty Slot', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    if (m != null)
                      Text('${m.condition} · ${m.dosage}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              Text(m?.status ?? 'Empty', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          if (m != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$qty tablets remaining', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                if (m.status == 'Low Stock') Text('Refill soon', style: TextStyle(color: Colors.orange, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: stockPercent(qty, max),
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
