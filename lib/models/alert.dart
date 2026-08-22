class Alert {
  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool read;
  final String? requestStatus; // NEW

  Alert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.read = false,
    this.requestStatus,
  });

  factory Alert.fromJson(Map<String, dynamic> json) => Alert(
        id: json['id'],
        type: json['type'],
        title: json['title'],
        message: json['message'],
        createdAt: DateTime.parse(json['created_at']),
        read: json['read'] ?? false,
        requestStatus: json['request_status'], // NEW
      );

  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  bool get isYesterday {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return createdAt.year == y.year &&
        createdAt.month == y.month &&
        createdAt.day == y.day;
  }
}
