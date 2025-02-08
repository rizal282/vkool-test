import 'package:ecommerce_vkool/data/model/order.dart';

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<OrderProduct> orders;
  PaymentLoaded({required this.orders});
}

class PaymentSuccess extends PaymentState {}

class PaymentError extends PaymentState {
  final String message;
  PaymentError({required this.message});
}
