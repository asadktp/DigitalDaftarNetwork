import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/org_repository.dart';
import '../../models/organization.dart';

class DonorDashboardScreen extends StatefulWidget {
  const DonorDashboardScreen({super.key});

  @override
  State<DonorDashboardScreen> createState() => _DonorDashboardScreenState();
}

class _DonorDashboardScreenState extends State<DonorDashboardScreen> {
  final OrgRepository _orgRepo = OrgRepository();
  List<Organization> _nearbyOrgs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final orgs = await _orgRepo.getOrganizations();
      if (mounted) {
        setState(() {
          _nearbyOrgs = orgs.take(5).toList();
          if (_nearbyOrgs.isEmpty) {
            // Mock data for preview
            _nearbyOrgs = [
              Organization(
                organizationId: 'org1',
                name: 'Darul Uloom',
                type: 'madarsa',
                city: 'Lucknow',
                address: 'Address 1',
                latitude: 0,
                longitude: 0,
                adminId: 'a1',
                status: 'approved',
                subscriptionPlan: 'Basic',
                createdAt: DateTime.now(),
              ),
              Organization(
                organizationId: 'org2',
                name: 'Masjid-e-Nabwi',
                type: 'mosque',
                city: 'Mumbai',
                address: 'Address 2',
                latitude: 0,
                longitude: 0,
                adminId: 'a2',
                status: 'approved',
                subscriptionPlan: 'Basic',
                createdAt: DateTime.now(),
              ),
            ];
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading donor dashboard: $e');
      if (mounted) {
        setState(() {
          _nearbyOrgs = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.user?.name ?? 'Friend';

    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryGreen,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assalamu Alaikum 👋',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Donate Banner
            _buildDonateBanner(context),
            const SizedBox(height: 24),
            // Quick actions
            _sectionTitle('Quick Actions'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.school,
                    label: 'Donate to\nMadarsa',
                    color: const Color(0xFF2E7D32),
                    onTap: () => context.push('/donate'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.mosque,
                    label: 'Donate to\nMosque',
                    color: const Color(0xFF00897B),
                    onTap: () => context.push('/donate'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.history,
                    label: 'Donation\nHistory',
                    color: AppConstants.secondaryGold,
                    onTap: () => context.push('/donor/history'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Nearby Organizations
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('Nearby Organizations'),
                TextButton(
                  onPressed: () => context.push('/orgs'),
                  child: const Text(
                    'See All',
                    style: TextStyle(color: AppConstants.primaryGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._nearbyOrgs.map((org) => _buildOrgCard(context, org)),
          ],
        ),
      ),
    );
  }

  Widget _buildDonateBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/donate'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF004D2E), AppConstants.primaryGreen],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryGreen.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Make a Difference',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Donate Today',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.secondaryGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Donate Now →',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.favorite_rounded, size: 80, color: Colors.white12),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrgCard(BuildContext context, Organization org) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryGreen.withValues(alpha: 0.1),
          child: Icon(
            org.type == 'madarsa' ? Icons.school : Icons.mosque,
            color: AppConstants.primaryGreen,
          ),
        ),
        title: Text(
          org.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${org.city} • ${org.type.toUpperCase()}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: ElevatedButton(
          onPressed: () => context.push('/donate'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryGreen,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Donate',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
