class UserProfile {
  final String id;
  final String fullName;
  final int age;
  final String gender;
  final String bloodGroup;
  final String mobile;
  final String city;
  final List<String> emergencyNames;
  final List<String> emergencyRelations;
  final List<String> emergencyPhones;
  final List<String> caregiverNames;
  final List<String> caregiverDesignations;
  final List<String> caregiverPhones;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.mobile,
    required this.city,
    required this.emergencyNames,
    required this.emergencyRelations,
    required this.emergencyPhones,
    required this.caregiverNames,
    required this.caregiverDesignations,
    required this.caregiverPhones,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Supabase arrays come as List<dynamic>; strings come as String.
    // This helper normalises both to List<String>.
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
      emergencyNames: toList(json['emergency_name']),
      emergencyRelations: toList(json['emergency_relation']),
      emergencyPhones: toList(json['emergency_phone']),
      caregiverNames: toList(json['caregiver_name']),
      caregiverDesignations: toList(json['caregiver_designation']),
      caregiverPhones: toList(json['caregiver_phone']),
    );
  }
}
