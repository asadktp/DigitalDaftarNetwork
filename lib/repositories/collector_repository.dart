import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/collector.dart';

class CollectorRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Collector>> getCollectors(String organizationId) async {
    final snapshot = await _db
        .collection('collectors')
        .where('organizationId', isEqualTo: organizationId)
        .get();

    return snapshot.docs.map((doc) => Collector.fromMap(doc.data())).toList();
  }

  Future<void> addCollector(Collector collector) async {
    await _db
        .collection('collectors')
        .doc(collector.collectorId)
        .set(collector.toMap());
  }

  Future<void> updateCollectorStatus(String collectorId, String status) async {
    await _db.collection('collectors').doc(collectorId).update({
      'status': status,
    });
  }
}

class MockCollectorRepository extends CollectorRepository {
  @override
  Future<List<Collector>> getCollectors(String organizationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Collector(
        collectorId: 'coll1',
        organizationId: organizationId,
        name: 'Zaid Khan',
        phone: '+91 99999 88888',
        status: 'active',
      ),
      Collector(
        collectorId: 'coll2',
        organizationId: organizationId,
        name: 'Umar Farooq',
        phone: '+91 77777 66666',
        status: 'active',
      ),
    ];
  }

  @override
  Future<void> addCollector(Collector collector) async {}
  @override
  Future<void> updateCollectorStatus(String collectorId, String status) async {}
}
