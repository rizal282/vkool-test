import 'package:ecommerce_vkool/data/model/cart.dart';

abstract class CartEvent {}

class AddToCart extends CartEvent {
  final Cart cartItem;

  AddToCart({required this.cartItem});
}

class LoadCartItems extends CartEvent {}