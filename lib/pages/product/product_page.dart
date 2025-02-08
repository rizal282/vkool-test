import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_vkool/blocs/cart/cart_bloc.dart';
import 'package:ecommerce_vkool/blocs/cart/cart_event.dart';
import 'package:ecommerce_vkool/blocs/cart/cart_state.dart';
import 'package:ecommerce_vkool/blocs/product/product_bloc.dart';
import 'package:ecommerce_vkool/blocs/product/product_event.dart';
import 'package:ecommerce_vkool/blocs/product/product_state.dart';
import 'package:ecommerce_vkool/data/model/cart.dart';
import 'package:ecommerce_vkool/repository/cart/cart_repository.dart';
import 'package:ecommerce_vkool/repository/product/product_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          create: (context) => CartBloc(
              cartRepository:
                  _cartRepository), // Pastikan CartBloc diinisialisasi di sini
        ),
      ],
      child: Scaffold(
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ProductLoaded) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns in the grid
                  childAspectRatio:
                      0.7, // Adjust aspect ratio for card height/width
                  crossAxisSpacing: 8.0, // Spacing between columns
                  mainAxisSpacing: 8.0, // Spacing between rows
                ),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          // Image takes up most of the card
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, object, stackTrace) {
                              return const Icon(
                                  Icons.image_not_supported); // Placeholder
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1, // Limit to one line
                                overflow:
                                    TextOverflow.ellipsis, // Handle overflow
                              ),
                              Text(
                                product.description,
                                maxLines: 2, // Limit description lines
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('\$${product.price.toStringAsFixed(2)}'),
                                  Text(
                                      'Stock: ${product.stock}'), // Display stock
                                ],
                              ),
                              BlocConsumer<CartBloc, CartState>(
                                listener: (context, state) {
                                  if (state is CartSuccess) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Added to cart!')),
                                    );
                                  } else if (state is CartError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(state.message)),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  return ElevatedButton(
                                    onPressed: () {
                                      final FirebaseAuth auth = FirebaseAuth.instance;
                                      
                                      context.read<CartBloc>().add(AddToCart(
                                          cartItem: Cart(
                                            userId: auth.currentUser!.uid,
                                              product: product, quantity: 1)));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .lightBlue, // Light blue background
                                      foregroundColor: Colors.white,
                                    ),
                                    child: state is CartLoading
                                        ? const CircularProgressIndicator()
                                        : const Text('Add to Cart'),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (state is ProductError) {
              return Center(child: Text(state.message));
            }

            return Center(child: Text("No products available"));
          },
        ),
      ),
    );
  }
}
