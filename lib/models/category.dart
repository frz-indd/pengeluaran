import 'package:flutter/material.dart';

class ExpenseCategory {
  final String name;
  final String emoji;
  final Color color;

  ExpenseCategory({
    required this.name,
    required this.emoji,
    required this.color,
  });
}

// Predefined categories
final List<ExpenseCategory> categories = [
  ExpenseCategory(
    name: 'Makanan',
    emoji: '🍽️',
    color: const Color(0xFFFF6B6B),
  ),
  ExpenseCategory(
    name: 'Transportasi',
    emoji: '🚗',
    color: const Color(0xFF4ECDC4),
  ),
  ExpenseCategory(name: 'Hiburan', emoji: '🎬', color: const Color(0xFFFFE66D)),
  ExpenseCategory(
    name: 'Kesehatan',
    emoji: '🏥',
    color: const Color(0xFF95E1D3),
  ),
  ExpenseCategory(
    name: 'Belanja',
    emoji: '🛍️',
    color: const Color(0xFFC7CEEA),
  ),
  ExpenseCategory(name: 'Tagihan', emoji: '📄', color: const Color(0xFFB4A7D6)),
  ExpenseCategory(
    name: 'Pendidikan',
    emoji: '🎓',
    color: const Color(0xFF74B9FF),
  ),
  ExpenseCategory(name: 'Lainnya', emoji: '📂', color: const Color(0xFFA29BFE)),
];

ExpenseCategory getCategoryByName(String name) {
  return categories.firstWhere(
    (cat) => cat.name == name,
    orElse: () => categories.last,
  );
}
