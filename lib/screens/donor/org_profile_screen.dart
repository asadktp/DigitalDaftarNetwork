import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../models/organization.dart';
import '../../repositories/org_repository.dart';

class OrgProfileScreen extends StatefulWidget {
  final String orgId;
  const OrgProfileScreen({super.key, required this.orgId});

  @override
  State<OrgProfileScreen> createState() => _OrgProfileScreenState();
}

class _OrgProfileScreenState extends State<OrgProfileScreen> {
  Organization? _org;
  bool _isLoading = true;

  final _repo = OrgRepository();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final org = await _repo.getOrganization(widget.orgId);
    if (mounted) {
      setState(() {
        _org = org;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_org == null) {
      return const Scaffold(
          body: Center(child: Text('Organization not found.')));
    }
    final org = _org!;
    final categories = AppConstants.getCategoriesForOrgType(org.type);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppConstants.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF004D2E), AppConstants.primaryGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          org.type == 'madarsa' ? Icons.school : Icons.mosque,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        org.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        org.type.toUpperCase(),
                        style: const TextStyle(
                          color: AppConstants.secondaryGold,
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info cards row
                  Row(
                    children: [
                      Expanded(child: _infoChip(Icons.location_city, org.city)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _infoChip(
                          Icons.verified,
                          org.status == 'approved' ? 'Verified' : 'Pending',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _infoChip(Icons.star, org.subscriptionPlan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Address
                  _buildSection('📍 Address', org.address),
                  const SizedBox(height: 16),
                  // About
                  _buildSection(
                    '📖 About',
                    'Registered ${org.type} located in ${org.city}. '
                        'Contributing to the community through education and worship.',
                  ),
                  const SizedBox(height: 16),
                  // Donation categories
                  const Text(
                    '💚 Accepted Donations',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories
                        .map(
                          (cat) => Chip(
                            label: Text(cat),
                            backgroundColor: AppConstants.primaryGreen
                                .withValues(alpha: 0.1),
                            labelStyle: const TextStyle(
                              color: AppConstants.primaryGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  // Donate button
                  ElevatedButton(
                    onPressed: () => context.push('/donate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      '💚 Donate Now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppConstants.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppConstants.primaryGreen, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppConstants.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(content, style: const TextStyle(color: Colors.grey, height: 1.6)),
      ],
    );
  }
}
