import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final snapshot = await _db.collection('category').get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<Map<String, dynamic>?> fetchCategoryById(String categoryId) async {
    final doc = await _db.collection('category').doc(categoryId).get();

    if (doc.exists) {
      return {...doc.data()!, 'id': doc.id};
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchCategoryByName(String categoryName) async {
    final querySnapshot = await _db
        .collection('category')
        .where('name', isEqualTo: categoryName)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return {...doc.data(), 'id': doc.id};
    } else {
      return null;
    }
  }

  Future<void> addCategory(String name) async {
    String? categoryId = await generateID();

    await _db.collection('category').doc(categoryId).set({
      'id': categoryId,
      'name': name,
    });
  }

  Future<String> generateID() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    final snapshot = await db.collection('category').orderBy('id').get();

    if (snapshot.docs.isEmpty) {
      return 'c001';
    }

    final lastId = snapshot.docs.last.id;

    int lastNumber = int.tryParse(lastId.substring(1)) ?? 0;

    int newNumber = lastNumber + 1;

    return 'c${newNumber.toString().padLeft(3, '0')}';
  }
}
