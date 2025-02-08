import 'package:ecommerce_vkool/data/model/cart.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<Cart> cartItems;

  CartLoaded(this.cartItems);
}

class CartSuccess extends CartState {}

class CartError extends CartState {
  final String message;

  CartError(this.message);
}