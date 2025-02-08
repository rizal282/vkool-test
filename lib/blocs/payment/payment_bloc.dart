import 'package:ecommerce_vkool/repository/order/order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce_vkool/blocs/payment/payment_event.dart';
import 'package:ecommerce_vkool/blocs/payment/payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final OrderRepository orderRepository;

  PaymentBloc({required this.orderRepository}) : super(PaymentInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<PayOrder>(_onPayOrder);
  }

  Future<void> _onLoadOrders(
      LoadOrders event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      final orders = await orderRepository.fetchOrders();
      emit(PaymentLoaded(orders: orders));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }

  Future<void> _onPayOrder(PayOrder event, Emitter<PaymentState> emit) async {
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulasi pembayaran
      emit(PaymentSuccess());
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }
}
