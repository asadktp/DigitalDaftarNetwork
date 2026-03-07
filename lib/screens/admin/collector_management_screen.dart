import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/collector.dart';
import '../../repositories/collector_repository.dart';

class CollectorManagementScreen extends StatefulWidget {
  final String orgId;
  const CollectorManagementScreen({super.key, required this.orgId});

  @override
  State<CollectorManagementScreen> createState() =>
      _CollectorManagementScreenState();
}

class _CollectorManagementScreenState extends State<CollectorManagementScreen> {
  final CollectorRepository _repo = AppConstants.useDummyData
      ? MockCollectorRepository()
      : CollectorRepository();
  List<Collector>? _collectors;

  @override
  void initState() {
    super.initState();
    _loadCollectors();
  }

  Future<void> _loadCollectors() async {
    final collectors = await _repo.getCollectors(widget.orgId);
    setState(() {
      _collectors = collectors;
    });
  }

  void _showAddCollectorDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Collector'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final collector = Collector(
                collectorId: DateTime.now().millisecondsSinceEpoch.toString(),
                organizationId: widget.orgId,
                name: nameController.text,
                phone: phoneController.text,
                status: 'active',
              );
              await _repo.addCollector(collector);
              if (!context.mounted) return;
              Navigator.pop(context);
              _loadCollectors();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Collectors')),
      body: _collectors == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _collectors!.length,
              itemBuilder: (context, index) {
                final collector = _collectors![index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppConstants.primaryGreen,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(collector.name),
                    subtitle: Text(collector.phone),
                    trailing: Switch(
                      value: collector.status == 'active',
                      onChanged: (value) async {
                        await _repo.updateCollectorStatus(
                          collector.collectorId,
                          value ? 'active' : 'inactive',
                        );
                        _loadCollectors();
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCollectorDialog,
        backgroundColor: AppConstants.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
