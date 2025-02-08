import 'package:ecommerce_vkool/blocs/transaction/transaction_event.dart';
import 'package:ecommerce_vkool/blocs/transaction/transaction_state.dart';
import 'package:ecommerce_vkool/data/model/transaction_product.dart';
import 'package:ecommerce_vkool/repository/transaction/transaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;

  TransactionBloc({required this.transactionRepository})
      : super(TransactionLoading()) {
    on<LoadTransactions>((event, emit) async {
      emit(TransactionLoading());
      try {
        final transactions = await transactionRepository.fetchTransactions(event.userId);
        emit(TransactionLoaded(transactions));
      } catch (e) {
        emit(TransactionError("Gagal mengambil transaksi: $e"));
      }
    });

    // on<AddTransaction>((event, emit) async {
    //   try {
    //     final newTransaction = TransactionProduct(
    //       id: '',
    //       orderId: event.,
    //       productName: event.productName,
    //       quantity: event.quantity,
    //       price: event.price,
    //       userId: event.userId,
    //       email: event.email,
    //       status: "Success", // Default status
    //       date: DateTime.now().toString(),
    //     );

    //     await transactionRepository.addTransaction(newTransaction);

    //     final updatedTransactions = await transactionRepository.fetchTransactions(event.userId);
    //     emit(TransactionLoaded(updatedTransactions));
    //   } catch (e) {
    //     emit(TransactionError("Gagal menambahkan transaksi"));
    //   }
    // });
  }
}