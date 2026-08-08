class Schedule {
  final String id;
  final String medicineId;
  final int slotNumber;
  final String time;
  final String repeatType;
  final bool active;

  Schedule({
    required this.id,
    required this.medicineId,
    required this.slotNumber,
    required this.time,
    required this.repeatType,
    this.active = true,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        id: json['id'],
        medicineId: json['medicine_id'],
        slotNumber: json['slot_number'],
        time: json['time'],
        repeatType: json['repeat_type'],
        active: json['active'] ?? true,
      );
}
