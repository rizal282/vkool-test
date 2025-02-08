import 'package:ecommerce_vkool/data/model/cart.dart';
import 'package:equatable/equatable.dart';

abstract class CheckoutEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckoutCart extends CheckoutEvent {
  final List<Cart> cartItems;

  CheckoutCart({required this.cartItems});

  @override
  List<Object> get props => [cartItems];
}
