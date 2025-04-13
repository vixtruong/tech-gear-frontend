import 'package:techgear/models/product/product_item.dart';
import 'package:techgear/models/product/variant_value.dart';

class GroupProductSpecs {
  List<ProductItem> productItems;
  List<VariantValue> specs;

  GroupProductSpecs({
    required this.productItems,
    required this.specs,
  });
}
