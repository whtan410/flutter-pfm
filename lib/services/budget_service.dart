import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget.dart';
import 'dart:developer';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  BudgetService(this.userId);

  // Get current month's budget
  Future<Budget?> getCurrentMonthBudget() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    try {
      final querySnapshot = await _firestore
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return Budget.fromMap(querySnapshot.docs.first.data());
    } catch (e) {
      log('Error getting budget: $e');
      return null;
    }
  }

    // Create or Update budget for current month
  Future<void> setBudget(double amount) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    try {
      final snapshot = await _firestore
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: DateTime(now.year, now.month + 1, 0))
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        await _firestore
            .collection('budgets')
            .doc(snapshot.docs.first.id)
            .update({'amount': amount});
      } else {
        final budgetId = _firestore.collection('budgets').doc().id;
        final budget = Budget(
          id: budgetId,
          userId: userId,
          amount: amount,
          date: startOfMonth,
        );
        
        await _firestore
            .collection('budgets')
            .doc(budgetId)
            .set(budget.toMap());
      }
    } catch (e) {
      log('Error setting budget: $e');
      throw Exception('Failed to set budget');
    }
  }

  // Delete budget
  Future<void> deleteBudget(String budgetId) async {
    try {
      await _firestore.collection('budgets').doc(budgetId).delete();
    } catch (e) {
      log('Error deleting budget: $e');
      throw Exception('Failed to delete budget');
    }
  }
}