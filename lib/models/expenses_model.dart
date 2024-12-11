import 'package:cloud_firestore/cloud_firestore.dart';

class ExpensesModel {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final String category;
  final DateTime date;

  ExpensesModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'amount': amount,
      'category': category,
      'date': date,
    };
  }

  factory ExpensesModel.fromMap(Map<String, dynamic> map) {
    return ExpensesModel(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      amount: (map['amount'] is int) 
          ? (map['amount'] as int).toDouble() 
          : map['amount'] as double,
      category: map['category'],
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}
