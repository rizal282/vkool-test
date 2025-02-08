import 'package:ecommerce_vkool/blocs/cart/cart_event.dart';
import 'package:ecommerce_vkool/blocs/cart/cart_state.dart';
import 'package:ecommerce_vkool/repository/cart/cart_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  CartBloc({required this.cartRepository}) : super(CartInitial()) {
    on<AddToCart>((event, emit) async {
      emit(CartLoading());

      try {
        await cartRepository.addItemToCart(event.cartItem);
        emit(CartSuccess());
      } catch (e) {
        emit(CartError(e.toString()));
      }
    });

    on<LoadCartItems>((event, emit) async {
      emit(CartLoading());
      try {
        final cartItems = await cartRepository.getCartItems();
        emit(CartLoaded(cartItems));
      } catch (e) {
        emit(CartError(e.toString()));
      }
    });
  }
}
