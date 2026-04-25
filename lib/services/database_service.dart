import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

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
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT
      )
    ''');
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
    return db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // Delete expense
  Future<int> deleteExpense(int id) async {
    final db = await database;
    return db.delete('expenses', where: 'id = ?', whereArgs: [id]);
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
}
