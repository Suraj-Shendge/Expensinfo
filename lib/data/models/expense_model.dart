class Expense {
  final int? id;
  final double amount;
  final String category;
  final String merchant;
  final DateTime date;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.merchant,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'merchant': merchant,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: (map['amount'] as num).toDouble(),
      category: map['category'],
      merchant: map['merchant'],
      date: DateTime.parse(map['date']),
    );
  }
}
