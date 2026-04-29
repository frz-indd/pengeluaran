import 'package:flutter/material.dart';

class ExpenseCategory {
  final String name;
  final String iconAsset;
  final Color color;

  ExpenseCategory({
    required this.name,
    required this.iconAsset,
    required this.color,
  });

  @Deprecated('Use iconAsset')
  String get emoji => iconAsset;
}

// Predefined categories
final List<ExpenseCategory> categories = [
  ExpenseCategory(
    name: 'Makanan',
    iconAsset: 'assets/meal.png',
    color: const Color(0xFFFF6B6B),
  ),
  ExpenseCategory(
    name: 'Transportasi',
    iconAsset: 'assets/service.png',
    color: const Color(0xFF4ECDC4),
  ),
  ExpenseCategory(
    name: 'Hiburan',
    iconAsset: 'assets/happiness.png',
    color: const Color(0xFFFFE66D),
  ),
  ExpenseCategory(
    name: 'Kesehatan',
    iconAsset: 'assets/hospital.png',
    color: const Color(0xFF95E1D3),
  ),
  ExpenseCategory(
    name: 'Belanja',
    iconAsset: 'assets/bag.png',
    color: const Color(0xFFC7CEEA),
  ),
  ExpenseCategory(
    name: 'Tagihan',
    iconAsset: 'assets/bill.png',
    color: const Color(0xFFB4A7D6),
  ),
  ExpenseCategory(
    name: 'Pendidikan',
    iconAsset: 'assets/school.png',
    color: const Color(0xFF74B9FF),
  ),
  ExpenseCategory(
    name: 'Lainnya',
    iconAsset: 'assets/folder.png',
    color: const Color(0xFFA29BFE),
  ),
];

ExpenseCategory getCategoryByName(String name) {
  return categories.firstWhere(
    (cat) => cat.name == name,
    orElse: () => categories.last,
  );
}
