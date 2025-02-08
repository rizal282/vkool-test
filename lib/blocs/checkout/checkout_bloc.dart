import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_vkool/blocs/checkout/checkout_event.dart';
import 'package:ecommerce_vkool/blocs/checkout/checkout_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CheckoutBloc({required this.firestore, required this.auth})
      : super(CheckoutInitial()) {
    on<CheckoutCart>(_onCheckoutCart);
  }

  Future<void> _onCheckoutCart(
      CheckoutCart event, Emitter<CheckoutState> emit) async {
    emit(CheckoutLoading());
    try {
      // Ambil user yang sedang login
      final User? user = auth.currentUser;
      if (user == null) {
        emit(CheckoutFailure(message: "User not logged in"));
        return;
      }

      // Simpan order dengan user ID
      await firestore.collection('orders').add({
        'userId': user.uid, 
        'items': event.cartItems
            .map((item) => {
                  'name': item.product.name,
                  'price': item.product.price,
                  'quantity': item.quantity
                })
            .toList(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      emit(CheckoutSuccess());
    } catch (e) {
      emit(CheckoutFailure(message: e.toString()));
    }
  }
}
