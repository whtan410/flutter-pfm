import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/expenses_model.dart';
import 'dart:developer';


class ExpensesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  ExpensesService(this.userId);

  // Get expenses stream
  Stream<List<ExpensesModel>> getExpenses() {
    return _firestore
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpensesModel.fromMap(doc.data()))
            .toList());
  }

    // Create expense
  Future<void> createExpense(ExpensesModel expense) async {
    await _firestore.collection('expenses').add(expense.toMap());
  }

  //Delete expense
  Future<void> deleteExpense(String expenseId) async {
    await _firestore
      .collection('expenses')
      .where('userId', isEqualTo: userId)
      .where('id', isEqualTo: expenseId)
      .get()
      .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.first.reference.delete();
        }
      });
  }

  // Get current month expenses grouped by category
  Future<Map<String, double>> getCurrentMonthExpenses() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    try {
      final querySnapshot = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      final Map<String, double> categoryTotals = {};
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final category = data['category'] as String;
        final amount = (data['amount'] as num).toDouble();
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }
      return categoryTotals;

    } catch (e) {
      return {};
    }
  }

  Future<Map<String, Map<String, double>>> getYearlyExpensesByCategory({required int selectedYear}) async {

    final startOfYear = DateTime(selectedYear, 1, 1);
    final endOfYear = DateTime(selectedYear, 12, 31);

    try {
      final querySnapshot = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfYear)
          .where('date', isLessThanOrEqualTo: endOfYear)
          .get();

      Map<String, Map<String, double>> monthlyExpenses = {};
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final month = DateFormat('MMM').format(date);
        final category = data['category'] as String;
        final amount = (data['amount'] as num).toDouble();

        monthlyExpenses.putIfAbsent(month, () => {});
        monthlyExpenses[month]![category] = (monthlyExpenses[month]![category] ?? 0) + amount;
      }

      return monthlyExpenses;
    } catch (e) {
      log('Error getting yearly expenses by category: $e');
      return {};
    }
  }
}

