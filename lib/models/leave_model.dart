class Leave {
  final int? id;
  final DateTime startDate;
  final DateTime endDate;
  final String type;
  final String reason;
  final String status; // 'approved', 'pending', 'rejected'
  final DateTime createdAt;

  Leave({
    this.id,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'type': type,
      'reason': reason,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Leave.fromMap(Map<String, dynamic> map) {
    return Leave(
      id: map['id'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      type: map['type'],
      reason: map['reason'],
      status: map['status'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  // Calculate number of days for this leave
  int get daysCount {
    return endDate.difference(startDate).inDays + 1;
  }

  // Check if leave is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate.subtract(const Duration(days: 1))) &&
           now.isBefore(endDate.add(const Duration(days: 1)));
  }

  Leave copyWith({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    String? reason,
    String? status,
    DateTime? createdAt,
  }) {
    return Leave(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}