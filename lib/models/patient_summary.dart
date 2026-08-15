class PatientSummary {
  final String id;
  final String name;
  final int age;
  final String? bloodGroup;
  final double adherence; // 0.0 - 1.0
  final String status; // Stable | Attention | Critical
  final bool isOnline;
  final String? lastActive;
  final String? nextMedName;
  final String? nextMedTime;
  final String? deviceStatus;
  final String? stockStatus;

  PatientSummary({
    required this.id,
    required this.name,
    required this.age,
    this.bloodGroup,
    required this.adherence,
    required this.status,
    this.isOnline = true,
    this.lastActive,
    this.nextMedName,
    this.nextMedTime,
    this.deviceStatus,
    this.stockStatus,
  });

  factory PatientSummary.fromJson(Map<String, dynamic> json) => PatientSummary(
        id: json['patient_id'] ?? json['id'],
        name: json['full_name'] ?? 'Unknown',
        age: json['age'] ?? 0,
        bloodGroup: json['blood_group'],
        adherence: (json['adherence'] ?? 0.0).toDouble(),
        status: json['status'] ?? 'Stable',
        isOnline: json['is_online'] ?? true,
        lastActive: json['last_active'],
        nextMedName: json['next_med_name'],
        nextMedTime: json['next_med_time'],
        deviceStatus: json['device_status'],
        stockStatus: json['stock_status'],
      );
}
