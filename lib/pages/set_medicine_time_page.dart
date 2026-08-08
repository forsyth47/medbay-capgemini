import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class SetMedicineTimePage extends StatefulWidget {
  const SetMedicineTimePage({super.key});

  @override
  State<SetMedicineTimePage> createState() => _SetMedicineTimePageState();
}

class _SetMedicineTimePageState extends State<SetMedicineTimePage> {
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  int _selectedSlot = 1;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  String _repeat = 'Daily';

  final List<String> _slots = ['s1', 's2', 's3', 's4'];
  final List<String> _repeatOptions = ['Daily', 'Alt. Days', 'Weekly'];

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty || _dosageCtrl.text.isEmpty) return;

    final timeStr =
        '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')} ${_time.period == DayPeriod.am ? 'AM' : 'PM'}';

    await SupabaseService.addSchedule({
      'medicine_id': null, // Link later if you want
      'slot_number': _selectedSlot,
      'time': timeStr,
      'repeat_type': _repeat,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule saved!')),
      );
      Navigator.pop(context);
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
            Text('Set Medicine Time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Schedule your medication',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputLabel('MEDICINE NAME'),
            _textField(_nameCtrl, 'e.g. Metformin 500mg'),
            const SizedBox(height: 16),
            _inputLabel('DOSAGE'),
            _textField(_dosageCtrl, 'e.g. 1 tablet after meals'),
            const SizedBox(height: 20),
            _inputLabel('SELECT SLOT'),
            Row(
              children: List.generate(4, (i) {
                final active = _selectedSlot == i + 1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSlot = i + 1),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: active ? Colors.blue.shade700 : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active
                              ? Colors.blue.shade700
                              : Colors.grey.shade300,
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
            const SizedBox(height: 20),
            _inputLabel('TIME'),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey.shade500),
                    const SizedBox(width: 12),
                    Text(
                      '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')} ${_time.period == DayPeriod.am ? 'AM' : 'PM'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _inputLabel('REPEAT'),
            Row(
              children: _repeatOptions.map((r) {
                final active = _repeat == r;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _repeat = r),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
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
                              ? Colors.blue.shade700
                              : Colors.grey.shade600,
                          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            const Text('Active Schedules',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Demo active schedules (static for UI match)
            _scheduleTile('Metformin 500mg', 's1 · Daily', '8:00 AM'),
            _scheduleTile('Atorvastatin 10mg', 's2 · Daily', '1:00 PM'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Save Schedule',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5)),
    );
  }

  Widget _textField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _scheduleTile(String name, String detail, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: Colors.blue.shade300, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(detail,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Text(time,
              style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }
}
