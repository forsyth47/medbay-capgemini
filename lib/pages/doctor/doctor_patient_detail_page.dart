import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/medicine.dart';
import '../../models/user_profile.dart';
import '../../services/supabase_service.dart';

class DoctorPatientDetailPage extends StatefulWidget {
  final String patientId;
  final String patientName;
  const DoctorPatientDetailPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<DoctorPatientDetailPage> createState() =>
      _DoctorPatientDetailPageState();
}

class _DoctorPatientDetailPageState extends State<DoctorPatientDetailPage> {
  Color get _primary => const Color(0xFF0D9488);
  UserProfile? patient;
  List<Medicine> medicines = [];
  List<Map<String, dynamic>> logs = [];
  Map<String, dynamic>? caretaker;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SupabaseService.getPatientProfile(widget.patientId);
    final m = await SupabaseService.getPatientMedicines(widget.patientId);
    final l = await SupabaseService.getPatientDispenseLogs(widget.patientId);
    final c = await SupabaseService.getCaretakerForPatient(widget.patientId);
    setState(() {
      patient = p;
      medicines = m;
      logs = l;
      caretaker = c;
      loading = false;
    });
  }

  Future<void> _call(String? number) async {
    if (number == null || number.isEmpty) return;
    final uri = Uri.parse('tel:${number.replaceAll(RegExp(r'\s+'), '')}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  double get _adherence {
    final relevant = logs
        .where((l) =>
            l['status'] == 'taken' ||
            l['status'] == 'missed' ||
            l['status'] == 'skipped')
        .toList();
    if (relevant.isEmpty) return 0.0;
    final taken = relevant.where((l) => l['status'] == 'taken').length;
    return taken / relevant.length;
  }

  int get _takenCount => logs.where((l) => l['status'] == 'taken').length;
  int get _missedCount => logs.where((l) => l['status'] == 'missed').length;
  int get _pendingCount => logs.where((l) => l['status'] == 'pending').length;

  Future<void> _removePatient() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Patient?'),
        content:
            const Text('This patient will no longer be under your care.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await SupabaseService.removePatientAccess(
        SupabaseService.currentUserId!,
        widget.patientId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient removed')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = patient?.fullName ?? widget.patientName;
    final age = patient?.age ?? '-';
    final blood = patient?.bloodGroup ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
            Text(name,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Patient · $age yrs · $blood',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Remove Patient',
            onPressed: _removePatient,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Patient Info ──
                  _sectionTitle('Patient Information'),
                  _card(
                    child: Column(
                      children: [
                        _infoRow('Full Name', patient?.fullName ?? '-'),
                        _infoRow('Age', '${patient?.age ?? '-'} years'),
                        _infoRow('Gender', patient?.gender ?? '-'),
                        _infoRow('Blood Group', patient?.bloodGroup ?? '-'),
                        _infoRow('Mobile', patient?.mobile ?? '-'),
                        _infoRow('City', patient?.city ?? '-'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Emergency Contacts ──
                  if (patient != null &&
                      patient!.emergencyNames.isNotEmpty) ...[
                    _sectionTitle('Emergency Contacts'),
                    _card(
                      child: Column(
                        children: List.generate(
                            patient!.emergencyNames.length, (i) {
                          final phone =
                              patient!.emergencyPhones.length > i
                                  ? patient!.emergencyPhones[i]
                                  : '';
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.shade50,
                              radius: 18,
                              child: const Icon(Icons.phone,
                                  color: Colors.red, size: 16),
                            ),
                            title: Text(patient!.emergencyNames[i],
                                style: const TextStyle(fontSize: 14)),
                            subtitle: Text(
                              '${patient!.emergencyRelations.length > i ? patient!.emergencyRelations[i] : ''} · $phone',
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.phone,
                                  color: Colors.green, size: 20),
                              onPressed: () => _call(phone),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Caretaker ──
                  _sectionTitle('Caretaker'),
                  _card(
                    child: caretaker == null
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('No caretaker assigned',
                                style: TextStyle(color: Colors.grey)),
                          )
                        : ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor:
                                  _primary.withValues(alpha: 0.1),
                              radius: 18,
                              child: Icon(Icons.medical_services,
                                  color: _primary, size: 16),
                            ),
                            title: Text(caretaker!['full_name'] ?? '-',
                                style: const TextStyle(fontSize: 14)),
                            subtitle: Text(caretaker!['mobile'] ?? '',
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(Icons.phone,
                                  color: Colors.green, size: 20),
                              onPressed: () =>
                                  _call(caretaker!['mobile']),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // ── Adherence Overview ──
                  _sectionTitle('Adherence Overview'),
                  _card(
                    child: Row(
                      children: [
                        SizedBox(
                          height: 90,
                          width: 90,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: _adherence,
                                strokeWidth: 8,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation(
                                  _adherence > 0.8
                                      ? _primary
                                      : Colors.orange,
                                ),
                              ),
                              Text('${(_adherence * 100).toInt()}%',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: [
                              _adherenceStat(
                                  'Taken', '$_takenCount', Colors.green),
                              const Divider(height: 12),
                              _adherenceStat(
                                  'Missed', '$_missedCount', Colors.red),
                              const Divider(height: 12),
                              _adherenceStat(
                                  'Pending', '$_pendingCount', Colors.blue),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Medicines ──
                  _sectionTitle('Current Medications'),
                  if (medicines.isEmpty)
                    _card(
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('No medications loaded',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ...medicines.map((m) => _medicineCard(m)),
                  const SizedBox(height: 16),

                  // ── Recent Dispense Logs ──
                  _sectionTitle('Recent Activity'),
                  if (logs.isEmpty)
                    _card(
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('No recent activity',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    _card(
                      child: Column(
                        children: logs.take(7).map((l) {
                          final status = l['status'] as String? ?? '';
                          final time = l['dispensed_at'] ??
                              l['scheduled_time'] ??
                              '';
                          final slot = l['slot_number'] ?? '-';
                          Color c = Colors.blue;
                          IconData ic = Icons.schedule;
                          if (status == 'taken') {
                            c = Colors.green;
                            ic = Icons.check_circle;
                          } else if (status == 'missed') {
                            c = Colors.red;
                            ic = Icons.cancel;
                          } else if (status == 'skipped') {
                            c = Colors.orange;
                            ic = Icons.remove_circle;
                          }
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            leading: Icon(ic, color: c, size: 18),
                            title: Text('Slot $slot · $status',
                                style: const TextStyle(fontSize: 13)),
                            trailing: Text(
                              time
                                  .toString()
                                  .split('T')
                                  .last
                                  .substring(0, 5),
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // ── Danger Zone ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: Colors.red.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber,
                                color: Colors.red.shade600),
                            const SizedBox(width: 8),
                            Text('Danger Zone',
                                style: TextStyle(
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Removing this patient will revoke your access to their medical data and they will no longer appear in your patient list.',
                          style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _removePatient,
                            icon: Icon(Icons.delete_outline,
                                color: Colors.red.shade600),
                            label: Text('Remove Patient',
                                style: TextStyle(
                                    color: Colors.red.shade600)),
                            style: OutlinedButton.styleFrom(
                              side:
                                  BorderSide(color: Colors.red.shade300),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155))),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _adherenceStat(String label, String val, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        Text(val,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _medicineCard(Medicine m) {
    final stockColor = m.quantity == 0
        ? Colors.red
        : m.quantity <= 5
            ? Colors.orange
            : Colors.green;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(m.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: stockColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(m.status,
                    style: TextStyle(
                        color: stockColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${m.dosage} · Slot ${m.slotNumber}',
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 12)),
          const SizedBox(height: 8),
          if (m.time != null && m.time!.isNotEmpty)
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text('${m.time} · ${m.repeatType ?? 'Daily'}',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: m.maxQuantity == 0 ? 0 : m.quantity / m.maxQuantity,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation(stockColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${m.quantity}/${m.maxQuantity} remaining',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
