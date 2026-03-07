import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class ExpenseRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<void> addExpense(Expense expense) async {
    await _db
        .collection('expenses')
        .doc(expense.expenseId)
        .set(expense.toMap());

    final summaryRef = _db
        .collection('org_summaries')
        .doc(expense.organizationId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(summaryRef);
      if (!snapshot.exists) {
        transaction.set(summaryRef, {
          'totalDonations': 0.0,
          'totalExpenses': expense.amount,
          'balance': -expense.amount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        double currentTotalExp =
            (snapshot.data()?['totalExpenses'] as num?)?.toDouble() ?? 0.0;
        double currentBalance =
            (snapshot.data()?['balance'] as num?)?.toDouble() ?? 0.0;

        transaction.update(summaryRef, {
          'totalExpenses': currentTotalExp + expense.amount,
          'balance': currentBalance - expense.amount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<List<Expense>> getExpenses(String orgId) async {
    final snapshot = await _db
        .collection('expenses')
        .where('organizationId', isEqualTo: orgId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList();
  }
}
