import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/category.dart';
import 'add_expense_screen.dart';
import 'expense_list_screen.dart';
import '../widgets/image_preview_dialog.dart';
import '../widgets/reminder_widget.dart';

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
      appBar: AppBar(title: const Text('My Outcome'), centerTitle: true),
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
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Riwayat'),
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
          // Reminder Widget
          const ReminderWidget(),

          /// 🔥 FIX OVERFLOW DI SINI
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: provider.previousMonth,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.chevron_left),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Text(
                      dateFormat.format(provider.selectedMonth),
                      style: Theme.of(context).textTheme.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: provider.nextMonth,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.chevron_right),
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
                      Theme.of(context).colorScheme.primary.withAlpha(179),
                    ],
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

          // Monthly stats chart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Pengeluaran (6 bulan terakhir)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: _buildMonthlySpendingChart(
                        context,
                        provider,
                        currencyFormat,
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
                            Text('${percentage.toStringAsFixed(1)}%'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 8,
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
                  Builder(
                    builder: (context) {
                      final sortedExpenses = [...provider.expenses]
                        ..sort((a, b) {
                          final byDate = b.date.compareTo(a.date);
                          if (byDate != 0) return byDate;
                          return (b.id ?? 0).compareTo(a.id ?? 0);
                        });
                      final hiddenCount = (sortedExpenses.length > 5)
                          ? sortedExpenses.length - 5
                          : 0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Pengeluaran Terbaru',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              if (hiddenCount > 0)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedIndex = 1;
                                    });
                                  },
                                  child: const Text('Lihat semua'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...sortedExpenses.take(5).map((expense) {
                            final category = getCategoryByName(
                              expense.category,
                            );
                            return ListTile(
                              leading: Text(category.emoji),
                              title: Text(expense.title),
                              subtitle: Text(
                                DateFormat(
                                  'dd MMM yyyy',
                                  'id_ID',
                                ).format(expense.date),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currencyFormat.format(expense.amount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (expense.imagePath != null &&
                                      expense.imagePath!.isNotEmpty) ...[
                                    const SizedBox(width: 10),
                                    InkWell(
                                      onTap: () => showImagePreviewDialog(
                                        context,
                                        imagePath: expense.imagePath!,
                                        title: expense.title,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(expense.imagePath!),
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  width: 44,
                                                  height: 44,
                                                  color: Colors.grey.shade200,
                                                  alignment: Alignment.center,
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    size: 18,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                          if (hiddenCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Pengeluaran lama: $hiddenCount (lihat di Riwayat)',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ),
                        ],
                      );
                    },
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

  Widget _buildMonthlySpendingChart(
    BuildContext context,
    ExpenseProvider provider,
    NumberFormat currencyFormat,
  ) {
    final data = provider.monthlyTotals;
    if (data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final maxY = data.fold<double>(0, (m, e) => e.total > m ? e.total : m);
    final safeMaxY = maxY <= 0 ? 1.0 : maxY * 1.2;

    String monthLabel(DateTime month) {
      final base = DateFormat('MMM', 'id_ID').format(month);
      final showYear = month.month == 1 || month == data.first.month;
      return showYear ? '$base\n${month.year}' : base;
    }

    return BarChart(
      BarChartData(
        maxY: safeMaxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final month = data[groupIndex].month;
              final label = DateFormat('MMM yyyy', 'id_ID').format(month);
              return BarTooltipItem(
                '$label\n${currencyFormat.format(rod.toY)}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 6,
                  child: Text(
                    monthLabel(data[index].month),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(data.length, (i) {
          final total = data[i].total;
          final color = Theme.of(context).colorScheme.primary;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: total,
                width: 14,
                borderRadius: BorderRadius.circular(6),
                color: color,
              ),
            ],
          );
        }),
      ),
    );
  }
}
