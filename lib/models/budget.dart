class Budget {
  final String id;
  final String userId;
  final double amount;
  final DateTime date;

  Budget({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'date': date,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      userId: map['userId'],
      amount: map['amount'].toDouble(),
      date: map['date'].toDate(),
    );
  }
}