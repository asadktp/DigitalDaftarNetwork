import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/donation.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/donation_repository.dart';
import '../../repositories/mock_donation_repository.dart';

class CollectorIntakeScreen extends StatefulWidget {
  final String orgId;
  const CollectorIntakeScreen({super.key, required this.orgId});

  @override
  State<CollectorIntakeScreen> createState() => _CollectorIntakeScreenState();
}

class _CollectorIntakeScreenState extends State<CollectorIntakeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _donorPhoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _donorNameController = TextEditingController();
  bool _isLoading = false;
  final String _selectedCategory = AppConstants.catGeneral;

  void _handleCollect() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final donationRepo = AppConstants.useDummyData
          ? MockDonationRepository()
          : DonationRepository();

      final donation = Donation(
        donationId: 'don_${DateTime.now().millisecondsSinceEpoch}',
        organizationId: widget.orgId,
        donorId: 'offline_${_donorPhoneController.text}',
        donorName: _donorNameController.text.isEmpty
            ? 'Offline Donor'
            : _donorNameController.text,
        donationCategory: _selectedCategory,
        amount: double.parse(_amountController.text),
        timestamp: DateTime.now(),
        collectorId: authProvider.user?.userId,
        status: 'completed',
        isOffline: true,
        paymentMethod: 'Cash',
        receiptNumber: 'REC-${DateTime.now().millisecondsSinceEpoch}',
      );

      await donationRepo.processDonation(donation);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Donation recorded successfully! Digital receipt generated.',
          ),
          backgroundColor: AppConstants.primaryGreen,
        ),
      );

      _amountController.clear();
      _donorPhoneController.clear();
      _donorNameController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to record donation: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Collection')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.qr_code_scanner,
                size: 64,
                color: AppConstants.primaryGreen,
              ),
              const SizedBox(height: 16),
              Text(
                'New Collection',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryGreen,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _donorPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Donor's Phone Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                validator: (val) =>
                    val!.isEmpty ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _donorNameController,
                decoration: InputDecoration(
                  labelText: "Donor's Name (Optional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount (₹)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.currency_rupee),
                ),
                validator: (val) {
                  if (val!.isEmpty) return 'Enter amount';
                  if (double.tryParse(val) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleCollect,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Collect & Sync',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
              const SizedBox(height: 16),
              const Text(
                'Note: A digital receipt link will be sent to the donor\'s phone upon completion.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
