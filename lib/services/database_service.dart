import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/monthly_total.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static const int _databaseVersion = 2;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'monthly_outcome.db');
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        imagePath TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _ensureColumnExists(
        db: db,
        table: 'expenses',
        column: 'imagePath',
        alterStatement: 'ALTER TABLE expenses ADD COLUMN imagePath TEXT',
      );
    }
  }

  Future<void> _ensureColumnExists({
    required Database db,
    required String table,
    required String column,
    required String alterStatement,
  }) async {
    final result = await db.rawQuery('PRAGMA table_info($table)');
    final hasColumn = result.any((row) => row['name'] == column);
    if (!hasColumn) {
      await db.execute(alterStatement);
    }
  }

  // Add a new expense
  Future<int> addExpense(Expense expense) async {
    final db = await database;
    return db.insert('expenses', expense.toMap());
  }

  // Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('expenses');
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  // Get expenses for specific month
  Future<List<Expense>> getExpensesByMonth(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(
      year,
      month + 1,
      1,
    ).subtract(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'category = ?',
      whereArgs: [category],
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  // Update expense
  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    final oldImagePath = await _getExpenseImagePathById(db: db, id: expense.id);

    final result = await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );

    await _deleteImageIfReplacedOrRemoved(
      oldImagePath: oldImagePath,
      newImagePath: expense.imagePath,
    );

    return result;
  }

  // Delete expense
  Future<int> deleteExpense(int id) async {
    final db = await database;
    final imagePath = await _getExpenseImagePathById(db: db, id: id);
    final result = await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
    await _deleteImageIfReplacedOrRemoved(
      oldImagePath: imagePath,
      newImagePath: null,
    );
    return result;
  }

  // Get total expenses for month
  Future<double> getTotalExpensesByMonth(int year, int month) async {
    final expenses = await getExpensesByMonth(year, month);
    return expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
  }

  // Get expenses grouped by category
  Future<Map<String, double>> getExpensesByMonthGroupedByCategory(
    int year,
    int month,
  ) async {
    final expenses = await getExpensesByMonth(year, month);
    final Map<String, double> groupedExpenses = {};

    for (final expense in expenses) {
      groupedExpenses[expense.category] =
          (groupedExpenses[expense.category] ?? 0) + expense.amount;
    }

    return groupedExpenses;
  }

  Future<List<MonthlyTotal>> getMonthlyTotals({
    required DateTime endMonth,
    int lastMonths = 6,
  }) async {
    final db = await database;
    final startMonth = DateTime(
      endMonth.year,
      endMonth.month - (lastMonths - 1),
      1,
    );
    final endExclusive = DateTime(endMonth.year, endMonth.month + 1, 1);

    final rows = await db.rawQuery(
      '''
SELECT substr(date, 1, 7) AS ym, SUM(amount) AS total
FROM expenses
WHERE date >= ? AND date < ?
GROUP BY ym
ORDER BY ym
''',
      [startMonth.toIso8601String(), endExclusive.toIso8601String()],
    );

    final totalsByYm = <String, double>{};
    for (final row in rows) {
      final ym = row['ym'] as String?;
      final total = row['total'];
      if (ym == null) continue;
      totalsByYm[ym] = (total is int)
          ? total.toDouble()
          : (total as num).toDouble();
    }

    final result = <MonthlyTotal>[];
    for (var i = 0; i < lastMonths; i++) {
      final month = DateTime(startMonth.year, startMonth.month + i, 1);
      final ymKey =
          '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}';
      result.add(MonthlyTotal(month: month, total: totalsByYm[ymKey] ?? 0));
    }

    return result;
  }

  Future<String?> _getExpenseImagePathById({
    required Database db,
    required int? id,
  }) async {
    if (id == null) return null;
    final rows = await db.query(
      'expenses',
      columns: ['imagePath'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['imagePath'] as String?;
  }

  Future<void> _deleteImageIfReplacedOrRemoved({
    required String? oldImagePath,
    required String? newImagePath,
  }) async {
    final oldPath = (oldImagePath ?? '').trim();
    final newPath = (newImagePath ?? '').trim();

    if (oldPath.isEmpty) return;
    if (newPath.isNotEmpty && newPath == oldPath) return;

    try {
      final file = File(oldPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best-effort cleanup: ignore failures (permissions, missing file, etc).
    }
  }
}
