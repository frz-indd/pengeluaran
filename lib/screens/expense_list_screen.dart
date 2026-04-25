import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  final ExpenseProvider provider;

  const ExpenseListScreen({super.key, required this.provider});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  String _filterCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
    );
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    // Filter expenses based on selected category
    List<Expense> filteredExpenses = widget.provider.expenses;
    if (_filterCategory != 'Semua') {
      filteredExpenses = filteredExpenses
          .where((expense) => expense.category == _filterCategory)
          .toList();
    }

    // Sort by date descending
    filteredExpenses.sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  selected: _filterCategory == 'Semua',
                  label: const Text('Semua'),
                  onSelected: (_) {
                    setState(() {
                      _filterCategory = 'Semua';
                    });
                  },
                ),
                ...categories.map((category) {
                  return FilterChip(
                    selected: _filterCategory == category.name,
                    avatar: Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    label: Text(category.name),
                    backgroundColor: category.color.withOpacity(0.2),
                    onSelected: (_) {
                      setState(() {
                        _filterCategory = category.name;
                      });
                    },
                  );
                }),
              ],
            ),
          ),
        ),

        // Expense List
        Expanded(
          child: filteredExpenses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📭', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada pengeluaran',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = filteredExpenses[index];
                    final category = getCategoryByName(expense.category);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              category.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        title: Text(
                          expense.title,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              expense.category,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: category.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              dateFormat.format(expense.date),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                            if (expense.description != null &&
                                expense.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                expense.description!,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                        trailing: Text(
                          currencyFormat.format(expense.amount),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddExpenseScreen(expenseToEdit: expense),
                            ),
                          );
                        },
                        onLongPress: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Text(
                                    '✏️',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  title: const Text('Edit'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddExpenseScreen(
                                          expenseToEdit: expense,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Text(
                                    '🗑️',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.red,
                                    ),
                                  ),
                                  title: const Text('Hapus'),
                                  textColor: Colors.red,
                                  onTap: () {
                                    Navigator.pop(context);
                                    widget.provider.deleteExpense(expense.id!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Pengeluaran dihapus'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
