import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ScannedMedicine {
  final String name;
  final String dose;
  final String timing;
  final String duration;
  final String note;

  ScannedMedicine({
    required this.name,
    required this.dose,
    required this.timing,
    required this.duration,
    required this.note,
  });

  factory ScannedMedicine.fromJson(Map<String, dynamic> json) =>
      ScannedMedicine(
        name: json['Name'] ?? json['name'] ?? '',
        dose: json['dose'] ?? '',
        timing: json['timing'] ?? '',
        duration: json['duration'] ?? '',
        note: json['note'] ?? '',
      );
}

class AIPrescriptionScannerPage extends StatefulWidget {
  const AIPrescriptionScannerPage({super.key});

  @override
  State<AIPrescriptionScannerPage> createState() =>
      _AIPrescriptionScannerPageState();
}

class _AIPrescriptionScannerPageState extends State<AIPrescriptionScannerPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _scanning = false;
  String? _prescriptionDate;
  List<ScannedMedicine> _results = [];

  // CHANGED: Single URL → List of fallback URLs
  // The app will try each one in order until one succeeds.
  final List<String> _backendUrls = [
    'http://backend.medbay.ianjosh.eu.org/parse', // Production backup
    'https://backend.medbay.ianjosh.eu.org/parse',
    'http://100.82.199.56:8000/parse', //s7-port tailscale
    'http://100.97.192.102:8000/parse',   // Linux tailscale
    'http://localhost:8000/parse'       // localhost for testing
  ];

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _image = picked;
        _results = [];
        _prescriptionDate = null;
      });
      await _scanImage(picked);
    }
  }

  // CHANGED: Loops through _backendUrls until one works
  Future<void> _scanImage(XFile file) async {
    setState(() => _scanning = true);

    Object? lastError;
    bool success = false;

    for (final url in _backendUrls) {
      try {
        final bytes = await file.readAsBytes();
        final request = http.MultipartRequest('POST', Uri.parse(url));
        request.files.add(
          http.MultipartFile.fromBytes('image', bytes, filename: file.name),
        );

        final response = await request.send().timeout(const Duration(seconds: 15));
        final respStr = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final data = jsonDecode(respStr);
          setState(() {
            _prescriptionDate = data['date']?.toString();
            final meds = data['medications'] as List<dynamic>? ?? [];
            _results = meds.map((m) => ScannedMedicine.fromJson(m)).toList();
          });
          success = true;
          // show toast/snackbar for success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Prescription scanned successfully! [$url]')),
          );
          break; // Stop trying other URLs once one succeeds
        } else {
          // Non-200 from this URL → log it and try next
          lastError = 'URL $url returned ${response.statusCode}';
        }
      } on FormatException catch (e) {
        // JSON parse error from this URL → try next
        lastError = 'URL $url bad JSON: $e';
      } catch (e) {
        // Network / timeout / connection error → try next
        lastError = 'URL $url failed: $e';
      }
    }

    setState(() => _scanning = false);

    if (!success && mounted) {
      _showError(
        'All servers failed.\nLast error: ${lastError ?? 'Unknown error'}',
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> _buyMedicine(String name, String dose) async {
    final query = Uri.encodeComponent('$name $dose 1mg.com near me');
    final url = Uri.parse('https://www.google.com/search?q=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _addToSupabase(ScannedMedicine med) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${med.name} added to medication list')),
    );
  }

  // ... keep the rest of the build(), _actionBtn(), _medicineCard(),
  // _detailRow() exactly as they were in the previous version ...
  // (Everything below this line is unchanged)

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
            Text('AI Prescription Scanner',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Scan & add medications instantly',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_image!.path),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.document_scanner_outlined,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text('No prescription selected',
                            style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    'Camera',
                    Icons.camera_alt,
                    Colors.blue.shade700,
                    () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionBtn(
                    'Gallery',
                    Icons.photo_library,
                    Colors.teal,
                    () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_scanning)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Colors.blue.shade700),
                    const SizedBox(height: 12),
                    Text('Analyzing prescription...',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            if (_results.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Detected Medications',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (_prescriptionDate != null)
                    Text('Date: $_prescriptionDate',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 12),
              ..._results.map((med) => _medicineCard(med)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _medicineCard(ScannedMedicine med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  med.name,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B)),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  med.dose,
                  style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _detailRow(Icons.access_time, 'Timing', med.timing),
          const SizedBox(height: 8),
          _detailRow(Icons.calendar_today, 'Duration', med.duration),
          const SizedBox(height: 8),
          _detailRow(Icons.note_alt, 'Note', med.note),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addToSupabase(med),
                  icon: Icon(Icons.add, color: Colors.blue.shade700),
                  label: Text('Add to List',
                      style: TextStyle(color: Colors.blue.shade700)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue.shade700),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _buyMedicine(med.name, med.dose),
                  icon: const Icon(Icons.shopping_cart, size: 18),
                  label: const Text('Buy'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
