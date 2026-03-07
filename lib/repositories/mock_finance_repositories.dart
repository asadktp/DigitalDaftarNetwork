import '../models/donation.dart';
import '../models/expense.dart';
import '../core/mock_data.dart';
import 'donation_repository.dart';
import 'expense_repository.dart';

class MockDonationRepository extends DonationRepository {
  @override
  Future<void> processDonation(Donation donation) async {}

  @override
  Future<List<Donation>> getDonationHistory(String orgId) async {
    return MockData.donations;
  }
}

class MockExpenseRepository extends ExpenseRepository {
  @override
  Future<void> addExpense(Expense expense) async {}

  @override
  Future<List<Expense>> getExpenses(String orgId) async {
    return MockData.expenses;
  }
}
