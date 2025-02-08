import 'package:ecommerce_vkool/data/model/product.dart';

class Cart {
  final Product product;
  final int quantity;
  final String userId;

  Cart({required this.product, required this.quantity, required this.userId});

  
}