import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../services/supabase_service.dart';

class LoadDispenserPage extends StatefulWidget {
  const LoadDispenserPage({super.key});

  @override
  State<LoadDispenserPage> createState() => _LoadDispenserPageState();
}

class _LoadDispenserPageState extends State<LoadDispenserPage> {
  List<Medicine> medicines = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await SupabaseService.getMedicines();
    setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Load Dispenser',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Configure medicine slots',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wifi, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Device connected · Ready to sync',
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: medicines.length,
                    itemBuilder: (ctx, i) => _slotCard(medicines[i]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Synced with ESP32!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.save),
                      label: const Text('Save & Sync Device',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('S${m.slotNumber}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Text('Slot ${m.slotNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              Text(m.status,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          _field('MEDICINE NAME', m.name),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _field('QUANTITY', '${m.quantity}')),
              const SizedBox(width: 12),
              Expanded(child: _field('EXPIRY DATE', m.expiryDate)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Stock Level',
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: m.stockPercent,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text('${m.quantity}/${m.maxQuantity} tablets',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        ],
      ),
    );
  }

    Widget _field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
