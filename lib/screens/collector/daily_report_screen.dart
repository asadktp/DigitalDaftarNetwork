import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../models/donation.dart';
import '../../repositories/donation_repository.dart';

class DailyReportScreen extends StatefulWidget {
  final String orgId;
  const DailyReportScreen({super.key, required this.orgId});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  final DonationRepository _repo = DonationRepository();
  List<Donation>? _donations;
  Map<String, double> _categoryBreakdown = {};
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await _repo.getDonationHistory(widget.orgId);
    final today = DateTime.now();
    final todayList = all
        .where(
          (d) =>
              d.timestamp.year == today.year &&
              d.timestamp.month == today.month &&
              d.timestamp.day == today.day,
        )
        .toList();

    final Map<String, double> breakdown = {};
    for (final d in todayList) {
      breakdown[d.donationCategory] =
          (breakdown[d.donationCategory] ?? 0) + d.amount;
    }

    if (mounted) {
      setState(() {
        _donations = todayList;
        _categoryBreakdown = breakdown;
        _totalAmount = todayList.fold(0, (s, d) => s + d.amount);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, dd MMM yyyy').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Collection Report'),
        actions: [IconButton(icon: const Icon(Icons.share), onPressed: () {})],
      ),
      body: _donations == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Date Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dateStr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppConstants.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Summary card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF004D2E), AppConstants.primaryGreen],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metric(
                          'Total Collected',
                          '₹${_totalAmount.toStringAsFixed(0)}',
                        ),
                        Container(width: 1, height: 50, color: Colors.white24),
                        _metric('Entries', '${_donations!.length}'),
                        Container(width: 1, height: 50, color: Colors.white24),
                        _metric('Categories', '${_categoryBreakdown.length}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Category breakdown
                  const Text(
                    'Category Breakdown',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ..._categoryBreakdown.entries.map(
                    (e) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.key,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '₹${e.value.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Collection list
                  const Text(
                    'All Collections',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (_donations!.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No collections today.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._donations!.asMap().entries.map((entry) {
                      final d = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppConstants.primaryGreen
                                .withValues(alpha: 0.1),
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: AppConstants.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            d.donorName ?? 'Anonymous',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${d.donationCategory} • ${DateFormat('hh:mm a').format(d.timestamp)}',
                          ),
                          trailing: Text(
                            '₹${d.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryGreen,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }
}
