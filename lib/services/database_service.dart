import 'package:sqflite/sqflite.dart' show Database, getDatabasesPath, openDatabase;
import 'package:path/path.dart';
import '../models/attendance_model.dart';
import '../models/leave_model.dart';
import '../models/shift_schedule_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chamcong_365.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL';

    // Create attendance table
    await db.execute('''
      CREATE TABLE attendance (
        id $idType,
        date $integerType,
        checkInTime INTEGER,
        checkOutTime INTEGER,
        shift $textType,
        status $textType,
        notes TEXT,
        workingHours $realType
      )
    ''');

    // Create leaves table
    await db.execute('''
      CREATE TABLE leaves (
        id $idType,
        startDate $integerType,
        endDate $integerType,
        type $textType,
        reason $textType,
        status $textType,
        createdAt $integerType
      )
    ''');

    // Create shift_schedules table
    await db.execute('''
      CREATE TABLE shift_schedules (
        id $idType,
        name $textType,
        morningStart $textType,
        morningEnd $textType,
        afternoonStart $textType,
        afternoonEnd $textType,
        isDefault INTEGER DEFAULT 0
      )
    ''');

    // Insert default shift schedule
    await db.insert('shift_schedules', {
      'name': 'Standard Schedule',
      'morningStart': '08:00',
      'morningEnd': '12:00',
      'afternoonStart': '13:30',
      'afternoonEnd': '17:30',
      'isDefault': 1,
    });
  }

  // Attendance methods
  Future<int> insertAttendance(Attendance attendance) async {
    final db = await instance.database;
    return await db.insert('attendance', attendance.toMap());
  }

  Future<List<Attendance>> getAttendanceByMonth(int year, int month) async {
    final db = await instance.database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);
    
    final maps = await db.query(
      'attendance',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => Attendance.fromMap(maps[i]));
  }

  Future<List<Attendance>> getAttendanceByDateRange(
      DateTime startDate, DateTime endDate) async {
    final db = await instance.database;
    
    final maps = await db.query(
      'attendance',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => Attendance.fromMap(maps[i]));
  }

  Future<Attendance?> getAttendanceByDate(DateTime date) async {
    final db = await instance.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final maps = await db.query(
      'attendance',
      where: 'date >= ? AND date < ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Attendance.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateAttendance(Attendance attendance) async {
    final db = await instance.database;
    return await db.update(
      'attendance',
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<int> deleteAttendance(int id) async {
    final db = await instance.database;
    return await db.delete(
      'attendance',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Leave methods
  Future<int> insertLeave(Leave leave) async {
    final db = await instance.database;
    return await db.insert('leaves', leave.toMap());
  }

  Future<List<Leave>> getAllLeaves() async {
    final db = await instance.database;
    final maps = await db.query('leaves', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => Leave.fromMap(maps[i]));
  }

  Future<List<Leave>> getLeavesByMonth(int year, int month) async {
    final db = await instance.database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);
    
    final maps = await db.query(
      'leaves',
      where: 'startDate <= ? AND endDate >= ?',
      whereArgs: [endDate.millisecondsSinceEpoch, startDate.millisecondsSinceEpoch],
      orderBy: 'startDate DESC',
    );

    return List.generate(maps.length, (i) => Leave.fromMap(maps[i]));
  }

  Future<List<Leave>> getLeavesByStatus(String status) async {
    final db = await instance.database;
    final maps = await db.query(
      'leaves',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) => Leave.fromMap(maps[i]));
  }

  Future<int> updateLeave(Leave leave) async {
    final db = await instance.database;
    return await db.update(
      'leaves',
      leave.toMap(),
      where: 'id = ?',
      whereArgs: [leave.id],
    );
  }

  Future<int> deleteLeave(int id) async {
    final db = await instance.database;
    return await db.delete(
      'leaves',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Shift Schedule methods
  Future<List<ShiftSchedule>> getAllShiftSchedules() async {
    final db = await instance.database;
    final maps = await db.query('shift_schedules');
    return List.generate(maps.length, (i) => ShiftSchedule.fromMap(maps[i]));
  }

  Future<ShiftSchedule?> getDefaultShiftSchedule() async {
    final db = await instance.database;
    final maps = await db.query(
      'shift_schedules',
      where: 'isDefault = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return ShiftSchedule.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertShiftSchedule(ShiftSchedule schedule) async {
    final db = await instance.database;
    return await db.insert('shift_schedules', schedule.toMap());
  }

  Future<int> updateShiftSchedule(ShiftSchedule schedule) async {
    final db = await instance.database;
    return await db.update(
      'shift_schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future<int> deleteShiftSchedule(int id) async {
    final db = await instance.database;
    return await db.delete(
      'shift_schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> setDefaultSchedule(int scheduleId) async {
    final db = await instance.database;
    // First, remove default from all schedules
    await db.update(
      'shift_schedules',
      {'isDefault': 0},
      where: 'isDefault = ?',
      whereArgs: [1],
    );
    
    // Then set the new default
    await db.update(
      'shift_schedules',
      {'isDefault': 1},
      where: 'id = ?',
      whereArgs: [scheduleId],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}