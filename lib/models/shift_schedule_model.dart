class ShiftSchedule {
  final int? id;
  final String name;
  final String morningStart;
  final String morningEnd;
  final String afternoonStart;
  final String afternoonEnd;
  final bool isDefault;

  ShiftSchedule({
    this.id,
    required this.name,
    required this.morningStart,
    required this.morningEnd,
    required this.afternoonStart,
    required this.afternoonEnd,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'morningStart': morningStart,
      'morningEnd': morningEnd,
      'afternoonStart': afternoonStart,
      'afternoonEnd': afternoonEnd,
      'isDefault': isDefault ? 1 : 0,
    };
  }

  factory ShiftSchedule.fromMap(Map<String, dynamic> map) {
    return ShiftSchedule(
      id: map['id'],
      name: map['name'],
      morningStart: map['morningStart'],
      morningEnd: map['morningEnd'],
      afternoonStart: map['afternoonStart'],
      afternoonEnd: map['afternoonEnd'],
      isDefault: map['isDefault'] == 1,
    );
  }

  // Calculate total working hours per day
  double get totalDailyHours {
    final morningHours = _calculateHours(morningStart, morningEnd);
    final afternoonHours = _calculateHours(afternoonStart, afternoonEnd);
    return morningHours + afternoonHours;
  }

  // Calculate hours between two time strings (HH:mm format)
  double _calculateHours(String startTime, String endTime) {
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);
    return end.difference(start).inMinutes / 60.0;
  }

  // Parse time string to DateTime
  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // Check if current time is within working hours
  bool get isCurrentlyWorkingTime {
    final now = DateTime.now();
    final currentTimeString = 
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    return _isTimeInRange(currentTimeString, morningStart, morningEnd) ||
           _isTimeInRange(currentTimeString, afternoonStart, afternoonEnd);
  }

  // Check if a time is within a range
  bool _isTimeInRange(String timeToCheck, String startTime, String endTime) {
    final check = _parseTime(timeToCheck);
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);
    
    return check.isAfter(start) && check.isBefore(end);
  }

  ShiftSchedule copyWith({
    int? id,
    String? name,
    String? morningStart,
    String? morningEnd,
    String? afternoonStart,
    String? afternoonEnd,
    bool? isDefault,
  }) {
    return ShiftSchedule(
      id: id ?? this.id,
      name: name ?? this.name,
      morningStart: morningStart ?? this.morningStart,
      morningEnd: morningEnd ?? this.morningEnd,
      afternoonStart: afternoonStart ?? this.afternoonStart,
      afternoonEnd: afternoonEnd ?? this.afternoonEnd,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}