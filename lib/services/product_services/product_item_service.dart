import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techgear/models/product_item.dart';
import 'package:techgear/services/google_services/google_drive_service.dart';

class ProductItemService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchProductItems() async {
    final snapshot = await _db
        .collection('product_item')
        .where('isDisabled', isEqualTo: false)
        // .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.reversed
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchProductItemsByProductId(
      String productId) async {
    final productRef = _db.doc('/product/$productId');
    final snapshot = await _db
        .collection('product_item')
        .where('product', isEqualTo: productRef)
        .where('isDisabled', isEqualTo: false)
        .get();
    return snapshot.docs.reversed
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();
  }

  Future<Map<String, dynamic>?> fetchProductItemById(
      String productItemId) async {
    final doc = await _db.collection('product_item').doc(productItemId).get();

    if (doc.exists) {
      return {...doc.data()!, 'id': doc.id};
    } else {
      return null;
    }
  }

  Future<void> addProductItem(ProductItem productItem) async {
    try {
      String productItemId = await generateID();

      final driveService = GoogleDriveService();
      await driveService.init();
      String? fileId = await driveService.uploadFile(productItem.imgFile);
      driveService.dispose();

      String imageUrl = "https://drive.google.com/uc?export=view&id=$fileId";

      await _db.collection('product_item').doc(productItemId).set({
        'id': productItemId,
        'SKU': productItem.sku,
        'price': productItem.price,
        'imageUrl': imageUrl,
        'quantity': productItem.quantity,
        'product': _db.collection('product').doc(productItem.productId),
        'createdAt': FieldValue.serverTimestamp(),
        'isDisabled': productItem.isDisabled,
      });
    } catch (e) {
      e.toString();
    }
  }

  Future<String> generateID() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    final snapshot = await db.collection('product_item').orderBy('id').get();

    if (snapshot.docs.isEmpty) {
      return 'pi001';
    }

    final lastId = snapshot.docs.last.id;

    int lastNumber = int.tryParse(lastId.substring(2)) ?? 0;

    int newNumber = lastNumber + 1;

    return 'pi${newNumber.toString().padLeft(3, '0')}';
  }
}
