import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/database_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  DateTime _selectedMonth = DateTime.now();
  DateTime get selectedMonth => _selectedMonth;

  double _totalExpenses = 0;
  double get totalExpenses => _totalExpenses;

  Map<String, double> _expensesByCategory = {};
  Map<String, double> get expensesByCategory => _expensesByCategory;

  ExpenseProvider() {
    loadExpenses();
  }

  // Load expenses for current month
  Future<void> loadExpenses() async {
    try {
      _expenses = await _databaseService.getExpensesByMonth(
        _selectedMonth.year,
        _selectedMonth.month,
      );
      _totalExpenses = await _databaseService.getTotalExpensesByMonth(
        _selectedMonth.year,
        _selectedMonth.month,
      );
      _expensesByCategory = await _databaseService
          .getExpensesByMonthGroupedByCategory(
            _selectedMonth.year,
            _selectedMonth.month,
          );
      notifyListeners();
    } catch (e) {
      print('Error loading expenses: $e');
    }
  }

  // Add new expense
  Future<void> addExpense(Expense expense) async {
    try {
      await _databaseService.addExpense(expense);
      await loadExpenses();
    } catch (e) {
      print('Error adding expense: $e');
    }
  }

  // Update expense
  Future<void> updateExpense(Expense expense) async {
    try {
      await _databaseService.updateExpense(expense);
      await loadExpenses();
    } catch (e) {
      print('Error updating expense: $e');
    }
  }

  // Delete expense
  Future<void> deleteExpense(int id) async {
    try {
      await _databaseService.deleteExpense(id);
      await loadExpenses();
    } catch (e) {
      print('Error deleting expense: $e');
    }
  }

  // Change month
  Future<void> changeMonth(DateTime newMonth) async {
    _selectedMonth = newMonth;
    await loadExpenses();
  }

  // Go to previous month
  Future<void> previousMonth() async {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    await loadExpenses();
  }

  // Go to next month
  Future<void> nextMonth() async {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    await loadExpenses();
  }

  // Get all expenses (not filtered by month)
  Future<List<Expense>> getAllExpenses() async {
    return _databaseService.getAllExpenses();
  }
}
