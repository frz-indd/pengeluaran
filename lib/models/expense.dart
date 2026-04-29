class Expense {
  final int? id;
  final String title;
  late final double amount;
  final String category;
  final DateTime date;
  final String? description;
  final String? imagePath; // 🔥 TAMBAHAN

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    this.imagePath, // 🔥 TAMBAHAN
  });

  // Convert Expense to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'imagePath': imagePath, // 🔥 TAMBAHAN
    };
  }

  // Create Expense from Map
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'].toDouble(),
      category: map['category'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      imagePath: map['imagePath'], // 🔥 TAMBAHAN
    );
  }

  // Copy with method for updates
  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
    String? imagePath,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath, 
    );
  }
}
