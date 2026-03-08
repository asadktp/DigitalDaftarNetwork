import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/app_user.dart';
import '../../models/organization.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/org_repository.dart';

class RegistrationScreen extends StatefulWidget {
  final String? initialRole;
  const RegistrationScreen({super.key, this.initialRole});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedRole;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  bool _isLoading = false;
  String _orgType = AppConstants.orgTypeMadarsa;
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? AppConstants.roleDonor;
  }

  void _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orgRepo = OrgRepository();

      final userId = authProvider.currentFirebaseUser?.uid ??
          'user_${DateTime.now().millisecondsSinceEpoch}';

      final userData = AppUser(
        userId: userId,
        name: _nameController.text,
        phone: authProvider.currentFirebaseUser?.phoneNumber ?? '+910000000000',
        role: _selectedRole,
        createdAt: DateTime.now(),
      );

      if (_selectedRole == AppConstants.roleOrgAdmin) {
        final org = Organization(
          organizationId: 'org_${DateTime.now().millisecondsSinceEpoch}',
          name: _orgNameController.text,
          type: _orgType,
          city: _cityController.text,
          address: _addressController.text.isNotEmpty
              ? _addressController.text
              : 'Address to be updated',
          latitude: 0.0,
          longitude: 0.0,
          adminId: userId,
          status: 'pending',
          subscriptionPlan: 'Basic',
          createdAt: DateTime.now(),
        );

        await orgRepo.createOrganization(org);
        userData.organizationId = org.organizationId;
      }

      await authProvider.updateUserData(userData);

      if (!mounted) return;

      if (_selectedRole == AppConstants.roleDonor) {
        context.go('/donor');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration submitted for approval.'),
            backgroundColor: AppConstants.primaryGreen,
          ),
        );
        context.go('/pending');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Your Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppConstants.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                items: const [
                  DropdownMenuItem(
                    value: AppConstants.roleDonor,
                    child: Text('Join as Donor'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.roleOrgAdmin,
                    child: Text('Register Madarsa/Mosque'),
                  ),
                ],
                onChanged: (val) => setState(() => _selectedRole = val!),
                decoration: InputDecoration(
                  labelText: 'I want to...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_pin),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (val) =>
                    val!.isEmpty ? 'Please enter your name' : null,
              ),
              if (_selectedRole == AppConstants.roleOrgAdmin) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _orgType,
                  items: const [
                    DropdownMenuItem(
                      value: AppConstants.orgTypeMadarsa,
                      child: Text('Madarsa (Islamic School)'),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.orgTypeMosque,
                      child: Text('Mosque (Masjid)'),
                    ),
                  ],
                  onChanged: (val) => setState(() => _orgType = val!),
                  decoration: InputDecoration(
                    labelText: 'Organization Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _orgNameController,
                  decoration: InputDecoration(
                    labelText: 'Madarsa/Mosque Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.account_balance),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Enter organization name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.location_city),
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter city' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Full Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.place),
                  ),
                ),
              ],
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleRegistration,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Complete Registration',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
