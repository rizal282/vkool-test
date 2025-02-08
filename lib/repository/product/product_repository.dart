import 'package:ecommerce_vkool/data/model/product.dart';
import 'package:ecommerce_vkool/data/service/firebase_service.dart';

class ProductRepository {
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> initializeProducts() => _firebaseService.initializeProducts();
  Future<List<Product>> fetchProducts() => _firebaseService.fetchProducts();
}
