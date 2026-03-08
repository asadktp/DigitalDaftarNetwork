import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/organization.dart';
import '../../repositories/org_repository.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final OrgRepository _repo = OrgRepository();
  List<Organization> _pendingOrgs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingOrganizations();
  }

  Future<void> _loadPendingOrganizations() async {
    setState(() => _isLoading = true);
    try {
      final allOrgs = await _repo.getOrganizations();
      if (allOrgs.isEmpty) {
        // Fallback for preview
        _pendingOrgs = [
          Organization(
            organizationId: 'org_mock_1',
            name: 'Demo Madarsa',
            type: 'madarsa',
            city: 'Mumbai',
            address: 'Andheri West',
            latitude: 0,
            longitude: 0,
            adminId: 'admin1',
            status: 'pending',
            subscriptionPlan: 'Basic',
            createdAt: DateTime.now(),
          ),
          Organization(
            organizationId: 'org_mock_2',
            name: 'Demo Mosque',
            type: 'mosque',
            city: 'Delhi',
            address: 'Old Delhi',
            latitude: 0,
            longitude: 0,
            adminId: 'admin2',
            status: 'pending',
            subscriptionPlan: 'Basic',
            createdAt: DateTime.now(),
          ),
        ];
      } else {
        _pendingOrgs = allOrgs.where((o) => o.status == 'pending').toList();
      }
    } catch (e) {
      debugPrint('Error loading orgs: $e');
      // Show mock data on error for visual testing
      _pendingOrgs = [
        Organization(
          organizationId: 'err_mock',
          name: 'Preview Mode (Data Load Error)',
          type: 'madarsa',
          city: 'Check Firebase Logs',
          address: 'Index might be missing',
          latitude: 0,
          longitude: 0,
          adminId: 'error',
          status: 'pending',
          subscriptionPlan: 'Basic',
          createdAt: DateTime.now(),
        ),
      ];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleApproval(String orgId, String decision) async {
    await _repo.updateOrganizationStatus(
      orgId,
      decision == 'Approved' ? 'approved' : 'rejected',
    );
    setState(() {
      _pendingOrgs.removeWhere((o) => o.organizationId == orgId);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Organization $decision successfully.'),
          backgroundColor: decision == 'Approved' ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingOrganizations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPlatformSummary(),
                  const SizedBox(height: 32),
                  Text(
                    'Pending Approvals (${_pendingOrgs.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (_pendingOrgs.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'No organizations awaiting approval.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ..._pendingOrgs.map((org) => _buildOrgApprovalCard(org)),
                ],
              ),
            ),
    );
  }

  Widget _buildPlatformSummary() {
    return Card(
      color: AppConstants.primaryGreen,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'PLATFORM OVERVIEW',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryStat('TOTAL ORGS', '1.2K'),
                _buildSummaryStat('TOTAL DONORS', '45K'),
                _buildSummaryStat('TOTAL COLLECTIONS', '₹85L+'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildOrgApprovalCard(Organization org) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppConstants.secondaryGold,
              child: Icon(Icons.account_balance, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    org.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    org.city,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () => _handleApproval(org.organizationId, 'Approved'),
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () => _handleApproval(org.organizationId, 'Rejected'),
            ),
          ],
        ),
      ),
    );
  }
}
