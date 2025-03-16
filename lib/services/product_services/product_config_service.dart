import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techgear/models/product_config.dart';

class ProductConfigService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchProductConfigs() async {
    final snapshot = await _db.collection('product_configuration').get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<List<Map<String, dynamic>>> fetchProductConfigsByProductItemId(
      String productItemId) async {
    final productItemRef = _db.doc('/product_item/$productItemId');
    final snapshot = await _db
        .collection('product_configuration')
        .where('product_item', isEqualTo: productItemRef)
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<void> addProductConfig(ProductConfig config) async {
    String? id = await generateID();

    await _db.collection('product_configuration').doc(id).set({
      'id': id,
      'product_item': _db.collection('product_item').doc(config.productItemId),
      "variant_value":
          _db.collection('variant_value').doc(config.variantValueId),
    });
  }

  Future<String> generateID() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    final snapshot =
        await db.collection('product_configuration').orderBy('id').get();

    if (snapshot.docs.isEmpty) {
      return 'pconf001';
    }

    final lastId = snapshot.docs.last.id;

    int lastNumber = int.tryParse(lastId.substring(5)) ?? 0;

    int newNumber = lastNumber + 1;

    return 'pconf${newNumber.toString().padLeft(3, '0')}';
  }
}
