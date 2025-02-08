import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_vkool/repository/order/order_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce_vkool/blocs/payment/payment_bloc.dart';
import 'package:ecommerce_vkool/blocs/payment/payment_event.dart';
import 'package:ecommerce_vkool/blocs/payment/payment_state.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentBloc(
        orderRepository: OrderRepository(
          firestore: FirebaseFirestore.instance,
          auth: FirebaseAuth.instance,
        ),
      )..add(LoadOrders()),
      child: Scaffold(
        appBar: AppBar(
            title: const Text(
          "Payment",
          style: TextStyle(color: Colors.blue),
        )),
        body: BlocConsumer<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is PaymentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pembayaran berhasil!')),
              );
            }
          },
          builder: (context, state) {
            if (state is PaymentLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PaymentLoaded) {
              final orders = state.orders;
              if (orders.isEmpty) {
                return const Center(child: Text("Tidak ada pesanan"));
              }

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pesanan ${order.id}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...order.items.map((item) => Text(
                              "${item['name']} - ${item['quantity']}x @ ${item['price']}")),
                          const Divider(),
                          const Text(
                            "Metode Pembayaran: Transfer Bank BCA",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text("No Rekening: 123-456-7890"),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final firestore = FirebaseFirestore.instance;
                              final userId = FirebaseAuth.instance.currentUser?.uid;
                              if (userId == null) return;

                              await firestore.runTransaction((transaction) async {
                                final orderRef = firestore.collection('orders').doc(order.id);
                                final transactionRef = firestore.collection('transactions').doc();

                                // Update order status
                                transaction.update(orderRef, {
                                  'status': 'paid',
                                  'payment_date': FieldValue.serverTimestamp(),
                                });

                                // Insert into transactions collection
                                transaction.set(transactionRef, {
                                  'id': transactionRef.id,
                                  'order_id': order.id,
                                  'product_name': order.items[0]['name'],
                                  'user_id': userId,
                                  'payment_method': 'Bank Transfer BCA',
                                  'status': 'success',
                                  'created_at': FieldValue.serverTimestamp(),
                                });
                              });

                              context.read<PaymentBloc>().add(PayOrder(orderId: order.id));
                            },
                            child: const Text(
                              "Pay Now",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is PaymentError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text("Belum ada transaksi"));
            }
          },
        ),
      ),
    );
  }
}
