import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techgear/models/variant_option.dart';

class VariantOptionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchVariantOptions() async {
    final snapshot = await _db
        .collection('variant_option')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<Map<String, dynamic>?> fetchVariantOptionById(String id) async {
    final doc = await _db.collection('variant_option').doc(id).get();

    if (doc.exists) {
      return {...doc.data()!, 'id': doc.id};
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchVariantOptionByName(String name) async {
    final querySnapshot = await _db
        .collection('variant_option')
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

  Future<List<Map<String, dynamic>>> fetchVariantOptionsByCateId(
      String cateId) async {
    final cateRef = _db.doc('/category/$cateId');

    final snapshot = await _db
        .collection('variant_option')
        .where('category', isEqualTo: cateRef)
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<void> addVariantOption(VariantOption option) async {
    String? id = await generateID();

    await _db.collection('variant_option').doc(id).set({
      'id': id,
      'name': option.name,
      'category': _db.collection('category').doc(option.categoryId),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> generateID() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    final snapshot = await db.collection('variant_option').orderBy('id').get();

    if (snapshot.docs.isEmpty) {
      return 'vo001';
    }

    final lastId = snapshot.docs.last.id;

    int lastNumber = int.tryParse(lastId.substring(2)) ?? 0;

    int newNumber = lastNumber + 1;

    return 'vo${newNumber.toString().padLeft(3, '0')}';
  }
}
