import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/donation.dart';
import '../../models/organization.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/donation_repository.dart';
import '../../repositories/org_repository.dart';

class DonationFlowScreen extends StatefulWidget {
  const DonationFlowScreen({super.key});

  @override
  State<DonationFlowScreen> createState() => _DonationFlowScreenState();
}

class _DonationFlowScreenState extends State<DonationFlowScreen> {
  // Step management
  int _currentStep = 0;

  // Selections
  String? _selectedOrgType; // 'madarsa' or 'mosque'
  Organization? _selectedOrg;
  String? _selectedCategory;
  final TextEditingController _amountController = TextEditingController();
  String _paymentMethod = 'UPI';
  bool _isLoading = false;

  final OrgRepository _orgRepo = OrgRepository();

  List<Organization> _filteredOrgs = [];
  bool _orgsLoading = false;

  Future<void> _loadOrgsByType(String type) async {
    setState(() => _orgsLoading = true);
    final orgs = await _orgRepo.getOrganizations(type: type);
    setState(() {
      _filteredOrgs = orgs;
      _orgsLoading = false;
    });
  }

  void _nextStep() {
    if (_currentStep < 3) setState(() => _currentStep++);
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _completeDonation() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final donationRepo = DonationRepository();

    final donation = Donation(
      donationId: 'don_${DateTime.now().millisecondsSinceEpoch}',
      organizationId: _selectedOrg!.organizationId,
      organizationType: _selectedOrg!.type,
      donorId: authProvider.user?.userId,
      donorName: authProvider.user?.name,
      donationCategory: _selectedCategory!,
      amount: amount,
      paymentMethod: _paymentMethod,
      timestamp: DateTime.now(),
      receiptNumber: 'REC-${DateTime.now().millisecondsSinceEpoch}',
    );

    try {
      await donationRepo.processDonation(donation);
      if (!mounted) return;
      _showReceiptDialog(donation);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Donation failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showReceiptDialog(Donation donation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppConstants.primaryGreen,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Jazakallah!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${donation.donationCategory} of ₹${donation.amount.toStringAsFixed(0)} has been recorded.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Receipt: ${donation.receiptNumber}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/donor');
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make a Donation'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _prevStep,
              )
            : null,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(key: ValueKey(_currentStep), child: _buildStep()),
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1SelectOrgType();
      case 1:
        return _buildStep2SelectOrg();
      case 2:
        return _buildStep3SelectCategory();
      case 3:
        return _buildStep4Payment();
      default:
        return const SizedBox();
    }
  }

  // STEP 1: Select Organization Type
  Widget _buildStep1SelectOrgType() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepHeader('Step 1 of 4', 'Where do you want to donate?'),
          const SizedBox(height: 32),
          _buildTypeCard(
            icon: Icons.school,
            title: 'Donate to a Madarsa',
            subtitle: 'Zakat • Sadaqah • Lillah • Imdad',
            value: AppConstants.orgTypeMadarsa,
          ),
          const SizedBox(height: 16),
          _buildTypeCard(
            icon: Icons.mosque,
            title: 'Donate to a Mosque',
            subtitle: 'Lillah • Imdad • General',
            value: AppConstants.orgTypeMosque,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final selected = _selectedOrgType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOrgType = value;
          _selectedOrg = null;
          _selectedCategory = null;
          _filteredOrgs = [];
        });
        _loadOrgsByType(value);
        _nextStep();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? AppConstants.primaryGreen.withValues(alpha: 0.1)
              : Colors.white,
          border: Border.all(
            color: selected ? AppConstants.primaryGreen : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppConstants.primaryGreen.withValues(
                alpha: 0.15,
              ),
              radius: 30,
              child: Icon(icon, color: AppConstants.primaryGreen, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // STEP 2: Select Organization
  Widget _buildStep2SelectOrg() {
    return Column(
      children: [
        _buildStepHeader(
          'Step 2 of 4',
          'Select a ${_selectedOrgType == AppConstants.orgTypeMadarsa ? "Madarsa" : "Mosque"}',
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _orgsLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredOrgs.isEmpty
                  ? const Center(child: Text('No organizations found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _filteredOrgs.length,
                      itemBuilder: (ctx, i) {
                        final org = _filteredOrgs[i];
                        final selected =
                            _selectedOrg?.organizationId == org.organizationId;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: selected
                                  ? AppConstants.primaryGreen
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppConstants.primaryGreen.withValues(
                                alpha: 0.1,
                              ),
                              child: Icon(
                                org.type == 'madarsa'
                                    ? Icons.school
                                    : Icons.mosque,
                                color: AppConstants.primaryGreen,
                              ),
                            ),
                            title: Text(
                              org.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(org.city),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              setState(() => _selectedOrg = org);
                              _nextStep();
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // STEP 3: Select Donation Category
  Widget _buildStep3SelectCategory() {
    final categories = AppConstants.getCategoriesForOrgType(_selectedOrg!.type);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepHeader('Step 3 of 4', 'Select Donation Type'),
          const SizedBox(height: 8),
          Text(
            _selectedOrg!.name,
            style: const TextStyle(
              color: AppConstants.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ...categories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCategoryTile(cat),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(String category) {
    final selected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = category);
        _nextStep();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppConstants.primaryGreen : Colors.white,
          border: Border.all(
            color: selected ? AppConstants.primaryGreen : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.monetization_on,
              color: selected ? Colors.white : AppConstants.primaryGreen,
            ),
            const SizedBox(width: 12),
            Text(
              category,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: selected ? Colors.white70 : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // STEP 4: Enter Amount & Pay
  Widget _buildStep4Payment() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepHeader('Step 4 of 4', 'Enter Amount'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppConstants.primaryGreen,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_selectedOrg!.name} • ${_selectedCategory!}',
                    style: const TextStyle(
                      color: AppConstants.primaryGreen,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: const TextStyle(fontSize: 24, color: Colors.grey),
              hintText: '0',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Quick amounts
          Wrap(
            spacing: 8,
            children: [100, 500, 1000, 2500, 5000].map((amt) {
              return ActionChip(
                label: Text('₹$amt'),
                onPressed: () => _amountController.text = amt.toString(),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Payment Method',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['UPI', 'Cash', 'Bank Transfer'].map((method) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(method),
                  selected: _paymentMethod == method,
                  onSelected: (_) => setState(() => _paymentMethod = method),
                  selectedColor: AppConstants.primaryGreen,
                  labelStyle: TextStyle(
                    color: _paymentMethod == method
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _completeDonation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: AppConstants.primaryGreen,
                  ),
                  child: const Text(
                    'Donate Now',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(
    String step,
    String title, {
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
