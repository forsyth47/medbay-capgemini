class UserProfile {
  final String id;
  final String fullName;
  final int age;
  final String gender;
  final String bloodGroup;
  final String mobile;
  final String city;
  final String email;
  final String role; // patient | doctor | caretaker
  final List<String> emergencyNames;
  final List<String> emergencyRelations;
  final List<String> emergencyPhones;
  final List<String> caregiverNames;
  final List<String> caregiverDesignations;
  final List<String> caregiverPhones;
  // Doctor-only
  final String? specialization;
  final String? hospital;
  final String? experience;
  final String? license;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.mobile,
    required this.city,
    this.email = '',
    this.role = 'patient',
    required this.emergencyNames,
    required this.emergencyRelations,
    required this.emergencyPhones,
    required this.caregiverNames,
    required this.caregiverDesignations,
    required this.caregiverPhones,
    this.specialization,
    this.hospital,
    this.experience,
    this.license,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    List<String> toList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      return [val.toString()];
    }

    return UserProfile(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      bloodGroup: json['blood_group'] ?? '',
      mobile: json['mobile'] ?? '',
      city: json['city'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'patient',
      emergencyNames: toList(json['emergency_name']),
      emergencyRelations: toList(json['emergency_relation']),
      emergencyPhones: toList(json['emergency_phone']),
      caregiverNames: toList(json['caregiver_name']),
      caregiverDesignations: toList(json['caregiver_designation']),
      caregiverPhones: toList(json['caregiver_phone']),
      specialization: json['specialization'],
      hospital: json['hospital'],
      experience: json['experience']?.toString(),
      license: json['license'],
    );
  }

  bool get isDoctor => role == 'doctor';
  bool get isCaretaker => role == 'caretaker';
  bool get isPatient => role == 'patient';
}
