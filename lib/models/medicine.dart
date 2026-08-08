class Medicine {
  final String id;
  final String name;
  final String dosage;
  final int slotNumber;
  final int quantity;
  final int maxQuantity;
  final String expiryDate;
  final String condition;
  final String status;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.slotNumber,
    required this.quantity,
    this.maxQuantity = 30,
    required this.expiryDate,
    required this.condition,
    required this.status,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
        id: json['id'],
        name: json['name'],
        dosage: json['dosage'],
        slotNumber: json['slot_number'],
        quantity: json['quantity'],
        maxQuantity: json['max_quantity'] ?? 30,
        expiryDate: json['expiry_date'],
        condition: json['condition'],
        status: json['status'],
      );

  double get stockPercent => quantity / maxQuantity;
}
