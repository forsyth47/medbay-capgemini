import 'package:flutter/material.dart';
import '../../../models/medicine.dart';
import '../../../services/supabase_service.dart';

class SetMedicineTimePage extends StatefulWidget {
  const SetMedicineTimePage({super.key});

  @override
  State<SetMedicineTimePage> createState() => _SetMedicineTimePageState();
}

class _SetMedicineTimePageState extends State<SetMedicineTimePage> {
  int slotCount = 4;
  int selectedSlot = 1;
  List<Medicine> medicines = [];
  bool loading = true;

  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
  String selectedRepeat = 'Daily';

  final List<String> _repeatOptions = ['Daily', 'Alt. Days', 'Weekly'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = SupabaseService.currentUserId!;
    slotCount = await SupabaseService.getSlotCount(uid);
    medicines = await SupabaseService.getMedicines(uid);
    _selectSlot(1);
    setState(() => loading = false);
  }

  Medicine? _medForSlot(int slot) {
    try {
      return medicines.firstWhere((m) => m.slotNumber == slot);
    } catch (_) {
      return null;
    }
  }

  void _selectSlot(int slot) {
    final med = _medForSlot(slot);
    final tod = _parseTime(med?.time);
    setState(() {
      selectedSlot = slot;
      selectedTime = tod ?? const TimeOfDay(hour: 8, minute: 0);
      selectedRepeat = med?.repeatType ?? 'Daily';
    });
  }

  TimeOfDay? _parseTime(String? t) {
    if (t == null || t.isEmpty) return null;
    try {
      final parts = t.split(' ');
      final hm = parts[0].split(':');
      var hour = int.parse(hm[0]);
      final minute = int.parse(hm[1]);
      if (parts[1] == 'PM' && hour != 12) hour += 12;
      if (parts[1] == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _save() async {
    final med = _medForSlot(selectedSlot);
    if (med == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Load a medicine in this slot first')),
      );
      return;
    }

    final timeStr =
        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')} ${selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}';

    await SupabaseService.updateMedicineById(med.id, {
      'time': timeStr,
      'repeat_type': selectedRepeat,
      'active': true,
    });

    // Keep local list in sync
    setState(() {
      medicines = medicines.map((m) {
        if (m.slotNumber == selectedSlot) {
          return Medicine(
            id: m.id,
            userId: m.userId,
            name: m.name,
            dosage: m.dosage,
            slotNumber: m.slotNumber,
            quantity: m.quantity,
            maxQuantity: m.maxQuantity,
            expiryDate: m.expiryDate,
            condition: m.condition,
            status: m.status,
            time: timeStr,
            repeatType: selectedRepeat,
            active: true,
          );
        }
        return m;
      }).toList();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final med = _medForSlot(selectedSlot);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Set Medicine Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Schedule your medication', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _inputLabel('SELECT SLOT'),
                  Row(
                    children: List.generate(slotCount, (i) {
                      final active = selectedSlot == i + 1;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _selectSlot(i + 1),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: active ? Colors.blue.shade700 : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: active ? Colors.blue.shade700 : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              's${i + 1}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: active ? Colors.white : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  if (med == null)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey.shade500),
                          const SizedBox(width: 12),
                          Text('No medicine loaded in Slot $selectedSlot',
                              style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.medication, color: Colors.blue.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(med.name,
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text(med.dosage,
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _inputLabel('TIME'),
                          GestureDetector(
                            onTap: _pickTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time,
                                      color: Colors.grey.shade500),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')} ${selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.edit,
                                      size: 16, color: Colors.grey.shade400),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _inputLabel('REPEAT'),
                          Row(
                            children: _repeatOptions.map((r) {
                              final active = selectedRepeat == r;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => selectedRepeat = r),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? Colors.blue.shade700
                                          : Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: active
                                            ? Colors.blue.shade700
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      r,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: active
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                        fontWeight: active
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                          if (med.time != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Updating existing schedule',
                                style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.save),
                      label: const Text('Save Schedule',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _inputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5)),
    );
  }
}
