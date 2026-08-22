class Medicine {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final int slotNumber;
  final int quantity;
  final int maxQuantity;
  final String expiryDate;
  final String condition;
  final String status;

  // Merged from schedules table
  final String? time;
  final String? repeatType;
  final bool? active;

  Medicine({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.slotNumber,
    required this.quantity,
    required this.maxQuantity,
    required this.expiryDate,
    required this.condition,
    required this.status,
    this.time,
    this.repeatType,
    this.active,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      slotNumber: json['slot_number'] as int,
      quantity: json['quantity'] as int,
      maxQuantity: json['max_quantity'] as int? ?? 25,
      expiryDate: json['expiry_date'] as String,
      condition: json['condition'] as String,
      status: json['status'] as String,
      time: json['time'] as String?,
      repeatType: json['repeat_type'] as String?,
      active: json['active'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'dosage': dosage,
      'slot_number': slotNumber,
      'quantity': quantity,
      'max_quantity': maxQuantity,
      'expiry_date': expiryDate,
      'condition': condition,
      'status': status,
      if (time != null) 'time': time,
      if (repeatType != null) 'repeat_type': repeatType,
      if (active != null) 'active': active,
    };
  }
}
