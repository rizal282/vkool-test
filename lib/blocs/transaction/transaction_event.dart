abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {
  final String userId;

  LoadTransactions({required this.userId});
}

class AddTransaction extends TransactionEvent {
  final String productName;
  final int quantity;
  final double price;
  final String userId;
  final String email;

  AddTransaction({
    required this.productName,
    required this.quantity,
    required this.price,
    required this.userId,
    required this.email,
  });
}
