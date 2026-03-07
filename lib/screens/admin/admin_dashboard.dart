import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/subscription_service.dart';
import '../../models/organization.dart';
import '../../models/org_summary.dart';
import '../../repositories/org_repository.dart';
import '../../repositories/mock_org_repository.dart';

class AdminDashboard extends StatefulWidget {
  final String orgId;
  const AdminDashboard({super.key, required this.orgId});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final OrgRepository _repo = AppConstants.useDummyData
      ? MockOrgRepository()
      : OrgRepository();
  OrgSummary? _summary;
  Organization? _organization;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      _repo.getSummary(widget.orgId),
      _repo.getOrganization(widget.orgId),
    ]);

    setState(() {
      _summary = results[0] as OrgSummary?;
      _organization = results[1] as Organization?;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: _summary == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummaryCard(
                    'Current Balance',
                    '₹${_summary!.balance.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                    AppConstants.primaryGreen,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Donations',
                          '₹${_summary!.totalDonations.toStringAsFixed(2)}',
                          Icons.trending_up,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Expenses',
                          '₹${_summary!.totalExpenses.toStringAsFixed(2)}',
                          Icons.trending_down,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard('Collectors', Icons.people, () {
                          if (_organization != null &&
                              SubscriptionService.isFeatureEnabled(
                                _organization!,
                                AppFeature.collectorManagement,
                              )) {
                            context.go('/admin/${widget.orgId}/collectors');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  SubscriptionService.getPlanGatingMessage(
                                    AppFeature.collectorManagement,
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          'Reports',
                          Icons.bar_chart,
                          () => context.go('/admin/${widget.orgId}/reports'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Financial Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            color: Colors.blue,
                            value: _summary!.totalDonations,
                            title: 'Donations',
                            radius: 50,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PieChartSectionData(
                            color: Colors.red,
                            value: _summary!.totalExpenses,
                            title: 'Expenses',
                            radius: 50,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: AppConstants.primaryGreen,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
