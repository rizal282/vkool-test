import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_vkool/blocs/cart/cart_bloc.dart';
import 'package:ecommerce_vkool/blocs/cart/cart_event.dart';
import 'package:ecommerce_vkool/blocs/cart/cart_state.dart';
import 'package:ecommerce_vkool/blocs/checkout/checkout_bloc.dart';
import 'package:ecommerce_vkool/blocs/checkout/checkout_event.dart';
import 'package:ecommerce_vkool/blocs/checkout/checkout_state.dart';
import 'package:ecommerce_vkool/blocs/payment/payment_bloc.dart';
import 'package:ecommerce_vkool/blocs/payment/payment_event.dart';
import 'package:ecommerce_vkool/pages/payment/payment_page.dart';
import 'package:ecommerce_vkool/repository/cart/cart_repository.dart';
import 'package:ecommerce_vkool/repository/order/order_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartRepository _cartRepository = CartRepository(
      firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              CartBloc(cartRepository: _cartRepository)..add(LoadCartItems()),
        ),
        BlocProvider(
          create: (context) => CheckoutBloc(
              firestore: FirebaseFirestore.instance,
              auth: FirebaseAuth.instance), // Pastikan CheckoutBloc ada di sini
        ),
        BlocProvider(
          create: (context) => PaymentBloc(
            orderRepository: OrderRepository(
              firestore: FirebaseFirestore.instance,
              auth: FirebaseAuth.instance,
            ),
          )..add(LoadOrders()), // Ensure you load the orders when initialized
        ),
      ],
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  if (state is CartLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CartLoaded) {
                    return ListView.builder(
                      itemCount: state.cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = state.cartItems[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.network(
                                  cartItem.product.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItem.product.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Quantity: ${cartItem.quantity}',
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${cartItem.product.price * cartItem.quantity}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is CartError) {
                    return Center(child: Text(state.message));
                  } else {
                    return const Center(child: Text('No items in cart'));
                  }
                },
              ),
            ),
            BlocConsumer<CheckoutBloc, CheckoutState>(
              listener: (context, state) {
                if (state is CheckoutSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to cart!')),
                  );
                } else if (state is CheckoutFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final cartState = context.read<CartBloc>().state;

                      if (cartState is CartLoaded) {
                        context
                            .read<CheckoutBloc>()
                            .add(CheckoutCart(cartItems: cartState.cartItems));

                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PaymentPage()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Cart is empty or not loaded')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Checkout',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
