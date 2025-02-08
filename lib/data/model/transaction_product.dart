class TransactionProduct {
  final String id;
  final String orderId;
  final String productName;
  final String paymentMethod;
  final int quantity;
  final double price;
  final String userId;
  final String email;
  final String status;
  final String date;

  TransactionProduct({
    required this.id,
    required this.orderId,
    required this.productName,
    required this.paymentMethod,
    required this.quantity,
    required this.price,
    required this.userId,
    required this.email,
    required this.status,
    required this.date,
  });

  factory TransactionProduct.fromJson(Map<String, dynamic> json, String id) {
    return TransactionProduct(
      id: id,
      orderId: json['order_id'],
      productName: json['product_name'],
      paymentMethod: json['payment_method'],
      quantity: 0,
      price: 0,
      userId: json['user_id'],
      email: '',
      status: json['status'],
      date: json['created_at'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'user_id': userId,
      'email': email,
      'status': status,
      // 'created_at': date.toIso8601String(),
    };
  }
}
