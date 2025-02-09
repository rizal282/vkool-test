import 'package:ecommerce_vkool/blocs/cart/cart_bloc.dart';
import 'package:ecommerce_vkool/blocs/cart/cart_state.dart';
import 'package:ecommerce_vkool/blocs/product/product_bloc.dart';
import 'package:ecommerce_vkool/blocs/product/product_event.dart';
import 'package:ecommerce_vkool/blocs/product/product_state.dart';
import 'package:ecommerce_vkool/repository/cart/cart_repository.dart';
import 'package:ecommerce_vkool/repository/product/product_repository.dart';
import 'package:ecommerce_vkool/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ProductRepository _productRepository = ProductRepository();
  final CartRepository _cartRepository = CartRepository(
      firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ProductBloc(_productRepository)..add(LoadProducts()),
        ),
        BlocProvider(
          create: (context) => CartBloc(cartRepository: _cartRepository),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text("Products")),
        body: BlocConsumer<CartBloc, CartState>(
          listener: (context, state) {
            if (state is CartSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to cart!')),
              );
            } else if (state is CartError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, cartState) {
            return BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductLoaded) {
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return ProductCard(product: product);
                    },
                  );
                } else if (state is ProductError) {
                  return Center(child: Text(state.message));
                }

                return const Center(child: Text("No products available"));
              },
            );
          },
        ),
      ),
    );
  }
}

