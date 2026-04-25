import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/category.dart';
import 'add_expense_screen.dart';
import 'expense_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran Bulanan'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          return _selectedIndex == 0
              ? _buildDashboard(context, provider)
              : _buildListView(context, provider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
        child: const Text(
          '+',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Text('🏠'), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Text('📋'), label: 'Riwayat'),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, ExpenseProvider provider) {
    final dateFormat = DateFormat('MMMM yyyy', 'id_ID');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          // Month Navigation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: provider.previousMonth,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '◀ Sebelumnya',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Text(
                  dateFormat.format(provider.selectedMonth),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                GestureDetector(
                  onTap: provider.nextMonth,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Selanjutnya ▶',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Total Expense Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pengeluaran',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(provider.totalExpenses),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Category Breakdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengeluaran per Kategori',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ...provider.expensesByCategory.entries.map((entry) {
                  final category = getCategoryByName(entry.key);
                  final percentage = provider.totalExpenses > 0
                      ? (entry.value / provider.totalExpenses) * 100
                      : 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              category.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.key),
                                  Text(
                                    currencyFormat.format(entry.value),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 8,
                            backgroundColor: category.color.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              category.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Recent Expenses
          if (provider.expenses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengeluaran Terbaru',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...provider.expenses.take(5).map((expense) {
                    final category = getCategoryByName(expense.category);
                    return ListTile(
                      leading: Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(expense.title),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy', 'id_ID').format(expense.date),
                      ),
                      trailing: Text(
                        currencyFormat.format(expense.amount),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

          if (provider.expenses.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const Text('💰', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada pengeluaran bulan ini',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap tombol + untuk menambah pengeluaran',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildListView(BuildContext context, ExpenseProvider provider) {
    return ExpenseListScreen(provider: provider);
  }
}
