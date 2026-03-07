class Expense {
  final String expenseId;
  final String organizationId;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String addedBy;

  Expense({
    required this.expenseId,
    required this.organizationId,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.addedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'expenseId': expenseId,
      'organizationId': organizationId,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'addedBy': addedBy,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      expenseId: map['expenseId'] ?? '',
      organizationId: map['organizationId'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(map['date']),
      addedBy: map['addedBy'] ?? '',
    );
  }
}
