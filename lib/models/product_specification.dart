import 'package:techgear/models/product_item.dart';
import 'package:techgear/models/variant_value.dart';

class ProductSpecification {
  String productId;
  List<Map<ProductItem, List<VariantValue>>> specs;
  List<Map<ProductItem, List<VariantValue>>>? colors;

  ProductSpecification({
    required this.productId,
    required this.specs,
    this.colors,
  });
}
