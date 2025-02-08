import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_vkool/blocs/transaction/transaction_bloc.dart';
import 'package:ecommerce_vkool/blocs/transaction/transaction_event.dart';
import 'package:ecommerce_vkool/blocs/transaction/transaction_state.dart';
import 'package:ecommerce_vkool/repository/transaction/transaction_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final transactionRepository =
        TransactionRepository(firestore: FirebaseFirestore.instance);

    return BlocProvider(
      create: (context) =>
          TransactionBloc(transactionRepository: transactionRepository)
            ..add(LoadTransactions(userId: user!.uid)),
      child: Scaffold(
        body: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is TransactionError) {
              return Center(child: Text(state.message));
            } else if (state is TransactionLoaded) {
              return ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: state.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = state.transactions[index];

                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      leading: Icon(
                        Icons.payment,
                        color: _getStatusColor(transaction.status),
                        size: 30,
                      ),
                      title: Text(
                        "Order ID: ${transaction.orderId}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text("Product Name: ${transaction.productName}"),
                          Text("Payment: ${transaction.paymentMethod}"),
                          Text("Status: ${transaction.status}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(transaction.status),
                              )),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Tambahkan navigasi ke halaman detail jika diperlukan
                      },
                    ),
                  );
                },
              );
            }

            return Center(
              child: Text("No Data Available"),
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }
}
