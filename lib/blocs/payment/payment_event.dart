abstract class PaymentEvent {}

class LoadOrders extends PaymentEvent {}

class PayOrder extends PaymentEvent {
  final String orderId;
  PayOrder({required this.orderId});
}
