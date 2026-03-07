import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/donation_repository.dart';
import '../../repositories/mock_donation_repository.dart';
import '../../models/donation.dart';
import 'package:intl/intl.dart';

class CollectorDashboardScreen extends StatefulWidget {
  final String orgId;
  const CollectorDashboardScreen({super.key, required this.orgId});

  @override
  State<CollectorDashboardScreen> createState() =>
      _CollectorDashboardScreenState();
}

class _CollectorDashboardScreenState extends State<CollectorDashboardScreen> {
  final DonationRepository _repo = AppConstants.useDummyData
      ? MockDonationRepository()
      : DonationRepository();
  List<Donation>? _todayDonations;
  double _todayTotal = 0;

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
              d.isOffline &&
              d.timestamp.year == today.year &&
              d.timestamp.month == today.month &&
              d.timestamp.day == today.day,
        )
        .toList();
    if (mounted) {
      setState(() {
        _todayDonations = todayList;
        _todayTotal = todayList.fold(0, (s, d) => s + d.amount);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryGreen,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Collector Panel',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              auth.user?.name ?? 'Collector',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              auth.signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Today's summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF004D2E), AppConstants.primaryGreen],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "Today's Collection",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${_todayTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_todayDonations?.length ?? 0} donations collected',
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    icon: Icons.add_circle,
                    label: 'New Collection',
                    color: AppConstants.primaryGreen,
                    onTap: () =>
                        context.push('/collector/intake/${widget.orgId}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionBtn(
                    icon: Icons.list_alt,
                    label: 'Daily Report',
                    color: AppConstants.secondaryGold,
                    onTap: () =>
                        context.push('/collector/report/${widget.orgId}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Today's Entries",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_todayDonations == null)
              const Center(child: CircularProgressIndicator())
            else if (_todayDonations!.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No collections yet today. Tap "New Collection" to add.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ..._todayDonations!.map((d) => _buildEntryTile(d)),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryTile(Donation d) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryGreen.withValues(alpha: 0.1),
          child: const Icon(Icons.person, color: AppConstants.primaryGreen),
        ),
        title: Text(
          d.donorName ?? 'Offline Donor',
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
  }
}
