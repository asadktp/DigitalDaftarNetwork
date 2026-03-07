import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/organization.dart';
import '../../repositories/org_repository.dart';
import '../../repositories/mock_org_repository.dart';
import '../../core/constants.dart';

class OrgDirectoryScreen extends StatefulWidget {
  const OrgDirectoryScreen({super.key});

  @override
  State<OrgDirectoryScreen> createState() => _OrgDirectoryScreenState();
}

class _OrgDirectoryScreenState extends State<OrgDirectoryScreen> {
  final OrgRepository _repo = AppConstants.useDummyData
      ? MockOrgRepository()
      : OrgRepository();
  List<Organization>? _organizations;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadOrgs();
  }

  Future<void> _loadOrgs() async {
    final orgs = await _repo.getOrganizations();
    setState(() {
      _organizations = orgs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Directory'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search city or name...',
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _organizations == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _organizations!.length,
              itemBuilder: (context, index) {
                final org = _organizations![index];
                if (!org.name.toLowerCase().contains(_searchQuery) &&
                    !org.city.toLowerCase().contains(_searchQuery)) {
                  return const SizedBox.shrink();
                }
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppConstants.primaryGreen.withValues(
                        alpha: 0.1,
                      ),
                      child: Icon(
                        org.type == 'madarsa' ? Icons.school : Icons.mosque,
                        color: AppConstants.primaryGreen,
                      ),
                    ),
                    title: Text(
                      org.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${org.city} • ${org.type.toUpperCase()}'),
                    trailing: ElevatedButton(
                      onPressed: () => context.push('/donate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Donate',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
