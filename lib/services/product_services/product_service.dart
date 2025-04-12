import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techgear/models/product.dart';
import 'package:techgear/services/google_services/google_drive_service.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final snapshot = await _db
        .collection('product')
        .where('isDisabled', isEqualTo: false)
        .get();
    return snapshot.docs.reversed
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();
  }

  Future<Map<String, dynamic>?> fetchProductById(String productId) async {
    final doc = await _db.collection('product').doc(productId).get();

    if (doc.exists) {
      return {...doc.data()!, 'id': doc.id};
    } else {
      return null;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      String productId = await generateID();

      final driveService = GoogleDriveService();
      await driveService.init();
      String? fileId = await driveService.uploadFile(product.imgFile);
      driveService.dispose();

      String directImageUrl =
          "https://lh3.googleusercontent.com/d/$fileId=w300";

      await _db.collection('product').doc(productId).set({
        'id': productId,
        'name': product.name,
        'price': product.price,
        'imageUrl': directImageUrl,
        'description': product.description,
        'brand': _db.collection('brand').doc(product.brandId),
        'category': _db.collection('category').doc(product.categoryId),
        'createdAt': FieldValue.serverTimestamp(),
        'isDisabled': product.available,
      });
    } catch (e) {
      e.toString();
    }
  }

  Future<String> generateID() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    final snapshot = await db.collection('product').orderBy('id').get();

    if (snapshot.docs.isEmpty) {
      return 'p001';
    }

    final lastId = snapshot.docs.last.id;

    int lastNumber = int.tryParse(lastId.substring(1)) ?? 0;

    int newNumber = lastNumber + 1;

    return 'p${newNumber.toString().padLeft(3, '0')}';
  }
}
