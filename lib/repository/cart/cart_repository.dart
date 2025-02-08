import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_vkool/data/model/cart.dart';
import 'package:ecommerce_vkool/data/model/product.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CartRepository({required this.firestore, required this.auth});

  Future<void> addItemToCart(Cart cartItem) async {
    final user = auth.currentUser;
    if (user != null) {
      final cartCollection = firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart');

      await cartCollection.add({
        'userId': user.uid,
        'productId': cartItem.product.id,
        'quantity': cartItem.quantity,
      });
    }
  }

  Future<List<Cart>> getCartItems() async {
    final user = auth.currentUser;

    if(user != null){
      final cartCollection = firestore.collection('users').doc(user.uid).collection('cart');

      final snapshot = await cartCollection.get();

      List<Cart> cartItems = []; 

      for (final doc in snapshot.docs) { // Iterasi snapshot.docs
      final data = doc.data() as Map<String, dynamic>;
      final productId = data['productId'];

      // Ambil data produk dari collection 'products'
      final productDoc = await firestore.collection('products').doc(productId).get();

      if (productDoc.exists) {
        final productData = productDoc.data() as Map<String, dynamic>;

        final product = Product(
          id: productId,
          name: productData['name'],
          imageUrl: productData['imageUrl'],
          description: productData['description'],
          price: productData['price'].toDouble(), // Pastikan konversi ke double jika perlu
          stock: productData['stock'], // Pastikan konversi ke tipe data yang sesuai
        );

        cartItems.add(Cart(
          product: product,
          quantity: data['quantity'],
          userId: data['userId'],
        ));
      } else {
        // Handle jika product tidak ditemukan (misalnya, log error)
        print('Error: Product with ID $productId not found!');
      }
    }
    return cartItems;
    } else {
      return [];
    }
  }
}