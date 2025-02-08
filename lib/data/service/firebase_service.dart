import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_vkool/data/model/product.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeProducts() async {
    CollectionReference products = _firestore.collection('products');

    QuerySnapshot snapshot = await products.get();

    if(snapshot.docs.isEmpty){
     List<Product> initialProducts = [
        Product(
          id: '1',
          name: 'Laptop',
          description: 'Laptop gaming terbaru dengan performa tinggi',
          price: 1500.0,
          imageUrl: 'https://img.freepik.com/free-photo/computer-laptop-old-vintage-book_1382-114.jpg?t=st=1738980050~exp=1738983650~hmac=59b3bdd37bbfc6d4237bcb0386a4c6ca7e921913d0fa2ee24a937502ecc9cdc9&w=996',
          stock: 50
        ),
        Product(
          id: '2',
          name: 'Smartphone',
          description: 'Smartphone flagship dengan kamera 108MP',
          price: 800.0,
          imageUrl: 'https://img.freepik.com/free-photo/new-cell-phone-colorful-background_58702-4893.jpg?t=st=1738980163~exp=1738983763~hmac=640ab6cb89a1fb6c516173f53173f01a903a964466c428e2b1aebbd76062b7b7&w=996',
          stock: 20
        ),
        Product(
          id: '3',
          name: 'Headphone',
          description: 'Headphone noise-canceling dengan suara jernih',
          price: 200.0,
          imageUrl: 'https://img.freepik.com/free-photo/headphones-displayed-against-dark-background_157027-4466.jpg?t=st=1738980218~exp=1738983818~hmac=6bfa9e30c27c4f955dce64d97a064bd67c36f45531283ec9c84b3f6edeb574b5&w=1380',
          stock: 30
        ),
        Product(
          id: '4',
          name: 'Smartwatch',
          description: 'Smartwatch dengan fitur pelacak kesehatan',
          price: 300.0,
          imageUrl: 'https://img.freepik.com/premium-photo/detailed-close-up-view-two-apple-watches-silver-gray-modern-retail-setting_536604-10220.jpg?w=996',
          stock: 60
        ),
        Product(
          id: '5',
          name: 'Keyboard Mechanical',
          description: 'Keyboard mechanical RGB untuk gaming',
          price: 120.0,
          imageUrl: 'https://img.freepik.com/premium-photo/mechanical-keyboard_9083-14355.jpg?w=996',
          stock: 50
        ),
      ];

      for(var product in initialProducts){
        await products.add(product.toMap());
      }

      print("Initialize Product Done!");
    }
  }

  Future<List<Product>> fetchProducts() async {
    QuerySnapshot snapshot = await _firestore.collection('products').get();

    return snapshot.docs.map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }
}