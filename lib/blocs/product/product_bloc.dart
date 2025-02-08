import 'package:ecommerce_vkool/blocs/product/product_event.dart';
import 'package:ecommerce_vkool/blocs/product/product_state.dart';
import 'package:ecommerce_vkool/repository/product/product_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {

  final ProductRepository _productRepository;

  ProductBloc(this._productRepository) : super(ProductInitial()) {
    on<LoadProducts>((event, emit) async {
      emit(ProductLoading());
      try {
        await _productRepository.initializeProducts();
        final products = await _productRepository.fetchProducts();

        print(products);

        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError("Failed to load products"));
      }
    });
  }

}