import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techgear/models/variant_value.dart';

class VariantValueService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchVariantValues() async {
    final snapshot = await _db
        .collection('variant_value')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<Map<String, dynamic>?> fetchVariantValueById(String id) async {
    final doc = await _db.collection('variant_value').doc(id).get();

    if (doc.exists) {
      return {...doc.data()!, 'id': doc.id};
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchVariantValueByName(String name) async {
    final querySnapshot = await _db
        .collection('variant_value')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return {...doc.data(), 'id': doc.id};
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchVariantValuesByOptionId(
      String optionId) async {
    final optionRef = _db.doc('/variant_option/$optionId');

    final snapshot = await _db
        .collection('variant_option')
        .where('variant_option', isEqualTo: optionRef)
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<void> addVariantValue(VariantValue value) async {
    String? id = await generateID();

    await _db.collection('variant_value').doc(id).set({
      'id': id,
      'name': value.name,
      'variant_option':
          _db.collection('variant_option').doc(value.variantOptionId),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> generateID() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    final snapshot = await db.collection('variant_value').orderBy('id').get();

    if (snapshot.docs.isEmpty) {
      return 'vl001';
    }

    final lastId = snapshot.docs.last.id;

    int lastNumber = int.tryParse(lastId.substring(2)) ?? 0;

    int newNumber = lastNumber + 1;

    return 'vl${newNumber.toString().padLeft(3, '0')}';
  }
}
