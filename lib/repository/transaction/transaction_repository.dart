import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_vkool/data/model/transaction_product.dart';

class TransactionRepository {
  final FirebaseFirestore firestore;

  TransactionRepository({required this.firestore});

  Future<List<TransactionProduct>> fetchTransactions(String userId) async {
    try {
      final snapshot = await firestore
          .collection('transactions')
          // .where('user_id', isEqualTo: userId)
          // .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => TransactionProduct.fromJson(doc.data(), doc.id),
          )
          .toList();
    } on FirebaseException catch (e) {
      print(e.message);
      throw Exception("Firestore Error: ${e.message}");
    } catch (e, stackTrace) {
      // Menangkap error umum
      print("Error: $e");
      print("Stack trace: $stackTrace");
      throw Exception("Gagal mengambil transaksi: ${e.toString()}");
    }
  }

  Future<void> addTransaction(TransactionProduct transaction) async {
    try {
      await firestore.collection('transactions').add(transaction.toJson());
    } catch (e) {
      throw Exception("Gagal menyimpan transaksi");
    }
  }
}
