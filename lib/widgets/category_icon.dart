import 'package:flutter/material.dart';

import '../models/category.dart';

class CategoryIcon extends StatelessWidget {
  final ExpenseCategory category;
  final double size;

  const CategoryIcon({super.key, required this.category, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      category.iconAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.broken_image, size: size);
      },
    );
  }
}

