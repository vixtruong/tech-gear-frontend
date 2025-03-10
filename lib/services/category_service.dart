import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category.dart';

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

  Future<void> addCategory(Category category) async {
    await _db.collection('category').doc(category.id).set({
      'name': category.name,
    });
  }
}
