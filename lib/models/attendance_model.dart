class Attendance {
  final int? id;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String shift; // 'morning', 'afternoon', 'full'
  final String status; // 'present', 'absent', 'leave'
  final String? notes;
  final double? workingHours;

  Attendance({
    this.id,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.shift,
    required this.status,
    this.notes,
    this.workingHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'checkInTime': checkInTime?.millisecondsSinceEpoch,
      'checkOutTime': checkOutTime?.millisecondsSinceEpoch,
      'shift': shift,
      'status': status,
      'notes': notes,
      'workingHours': workingHours,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      checkInTime: map['checkInTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['checkInTime'])
          : null,
      checkOutTime: map['checkOutTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['checkOutTime'])
          : null,
      shift: map['shift'],
      status: map['status'],
      notes: map['notes'],
      workingHours: map['workingHours']?.toDouble(),
    );
  }

  Attendance copyWith({
    int? id,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? shift,
    String? status,
    String? notes,
    double? workingHours,
  }) {
    return Attendance(
      id: id ?? this.id,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      shift: shift ?? this.shift,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      workingHours: workingHours ?? this.workingHours,
    );
  }
}