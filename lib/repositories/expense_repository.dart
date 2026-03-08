import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';
import 'package:flutter/foundation.dart';

class ExpenseRepository {
  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // Mock data for fallback
  final List<Expense> _mockExpenses = [
    Expense(
      expenseId: 'e1',
      organizationId: 'org1',
      title: 'Electricity Bill',
      amount: 2500,
      category: 'Utilities',
      date: DateTime.now().subtract(const Duration(days: 2)),
      addedBy: 'admin1',
    ),
    Expense(
      expenseId: 'e2',
      organizationId: 'org1',
      title: 'Maintenance',
      amount: 5000,
      category: 'Maintenance',
      date: DateTime.now().subtract(const Duration(days: 5)),
      addedBy: 'admin1',
    ),
  ];

  Future<void> addExpense(Expense expense) async {
    if (_db == null) return;
    await _db!
        .collection('expenses')
        .doc(expense.expenseId)
        .set(expense.toMap());
  }

  Future<List<Expense>> getExpenses(String orgId) async {
    if (_db == null) {
      debugPrint('Firestore unavailable, returning mock expenses.');
      return _mockExpenses;
    }
    try {
      final snapshot = await _db!
          .collection('expenses')
          .where('organizationId', isEqualTo: orgId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Expense.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Firestore Error in getExpenses: $e');
      return _mockExpenses;
    }
  }
}
