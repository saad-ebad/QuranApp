class AppLog {
  final int? id;
  final String message;
  final DateTime timestamp;

  AppLog({
    this.id,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AppLog.fromMap(Map<String, dynamic> map) {
    return AppLog(
      id: map['id'],
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
