import 'package:cloud_firestore/cloud_firestore.dart';

class BrandService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchBrands() async {
    final snapshot = await _db.collection('brand').get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<Map<String, dynamic>?> fetchBrandById(String brandId) async {
    final doc = await _db.collection('brand').doc(brandId).get();

    if (doc.exists) {
      return {...doc.data()!, 'id': doc.id};
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchBrandByName(String brandName) async {
    final querySnapshot = await _db
        .collection('brand')
        .where('name', isEqualTo: brandName)
        .limit(1) // Chỉ lấy 1 kết quả
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return {...doc.data(), 'id': doc.id};
    } else {
      return null;
    }
  }

  Future<void> addBrand(String brand) async {
    String? id = await generateID();

    await _db.collection('brand').doc(id).set({
      'id': id,
      'name': brand,
    });
  }

  Future<String> generateID() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    final snapshot = await db.collection('brand').orderBy('id').get();

    if (snapshot.docs.isEmpty) {
      return 'b001';
    }

    final lastId = snapshot.docs.last.id;

    int lastNumber = int.tryParse(lastId.substring(1)) ?? 0;

    int newNumber = lastNumber + 1;

    return 'b${newNumber.toString().padLeft(3, '0')}';
  }
}
