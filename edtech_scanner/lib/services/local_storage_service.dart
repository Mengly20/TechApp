import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/models/scan_model.dart';
import '../core/constants/app_constants.dart';

class LocalStorageService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE local_scans (
        scan_id TEXT PRIMARY KEY,
        user_id TEXT,
        equipment_id TEXT NOT NULL,
        equipment_name TEXT NOT NULL,
        class_name TEXT NOT NULL,
        confidence_score REAL NOT NULL,
        image_path TEXT NOT NULL,
        thumbnail_path TEXT,
        timestamp TEXT NOT NULL,
        synced_to_backend INTEGER DEFAULT 0,
        notes TEXT
      )
    ''');

    await db.execute('CREATE INDEX idx_local_scans_timestamp ON local_scans(timestamp DESC)');
    await db.execute('CREATE INDEX idx_local_scans_user_id ON local_scans(user_id)');
  }

  Future<void> saveScan(ScanModel scan) async {
    final db = await database;
    await db.insert(
      'local_scans',
      scan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ScanModel>> getAllScans() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'local_scans',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return ScanModel.fromJson(maps[i]);
    });
  }

  Future<ScanModel?> getScanById(String scanId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'local_scans',
      where: 'scan_id = ?',
      whereArgs: [scanId],
    );

    if (maps.isNotEmpty) {
      return ScanModel.fromJson(maps.first);
    }
    return null;
  }

  Future<void> deleteScan(String scanId) async {
    final db = await database;
    await db.delete(
      'local_scans',
      where: 'scan_id = ?',
      whereArgs: [scanId],
    );
  }

  Future<void> clearAllScans() async {
    final db = await database;
    await db.delete('local_scans');
  }

  Future<int> getScanCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM local_scans');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
