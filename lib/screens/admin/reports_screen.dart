import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants.dart';
import '../../models/expense.dart';
import '../../repositories/expense_repository.dart';
import '../../repositories/donation_repository.dart';
import '../../models/donation.dart';

class ReportsScreen extends StatefulWidget {
  final String orgId;
  const ReportsScreen({super.key, required this.orgId});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ExpenseRepository _expRepo = ExpenseRepository();
  final DonationRepository _donRepo = DonationRepository();

  List<Expense>? _expenses;
  List<Donation>? _donations;
  Map<String, double> _categoryTotals = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final expenses = await _expRepo.getExpenses(widget.orgId);
    final donations = await _donRepo.getDonationHistory(widget.orgId);

    final Map<String, double> catTotals = {};
    for (final d in donations) {
      catTotals[d.donationCategory] =
          (catTotals[d.donationCategory] ?? 0) + d.amount;
    }

    setState(() {
      _expenses = expenses;
      _donations = donations;
      _categoryTotals = catTotals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Reports')),
      body: (_expenses == null || _donations == null)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Donation Category Breakdown (The key requirement)
                  _buildSectionHeader('Donation Category Breakdown'),
                  const SizedBox(height: 12),
                  if (_categoryTotals.isEmpty)
                    const _EmptyCard(message: 'No donations recorded yet.')
                  else
                    ..._categoryTotals.entries.map(
                      (entry) => _buildCategoryRow(entry.key, entry.value),
                    ),
                  const SizedBox(height: 24),

                  // Expense Chart
                  _buildSectionHeader('Expense Breakdown'),
                  const SizedBox(height: 12),
                  if (_expenses!.isEmpty)
                    const _EmptyCard(message: 'No expenses recorded.')
                  else
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          barGroups: _expenses!.asMap().entries.map((e) {
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.amount,
                                  color: AppConstants.secondaryGold,
                                  width: 16,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Expense logs
                  _buildSectionHeader('Expense Logs'),
                  const SizedBox(height: 8),
                  ..._expenses!.map(
                    (exp) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(exp.title),
                        subtitle: Text(exp.category),
                        trailing: Text(
                          '₹${exp.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCategoryRow(String category, double amount) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryGreen.withValues(alpha: 0.1),
          child: const Icon(
            Icons.monetization_on,
            color: AppConstants.primaryGreen,
            size: 20,
          ),
        ),
        title: Text(
          'Total $category',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Text(
          '₹${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryGreen,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
