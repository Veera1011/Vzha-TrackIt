import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/transactions/data/models/transaction_model.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (kIsWeb) {
      throw UnsupportedError('Isar 3.x does not support Web yet. Use mobile/desktop or direct Supabase.');
    }
    if (Isar.instanceNames.isEmpty) {
      String? path;
      final dir = await getApplicationDocumentsDirectory();
      path = dir.path;
      return await Isar.open(
        [TransactionModelSchema],
        directory: path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  // Transactions
  Future<void> saveTransaction(TransactionModel transaction) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.transactionModels.putSync(transaction));
  }

  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final isar = await db;
    isar.writeTxnSync(() {
      isar.transactionModels.putAllSync(transactions);
    });
  }

  Future<List<TransactionModel>> getTransactions(String tenantId) async {
    final isar = await db;
    return await isar.transactionModels.filter().tenantIdEqualTo(tenantId).sortByDateDesc().findAll();
  }

  Future<void> clearTransactions() async {
    final isar = await db;
    isar.writeTxnSync(() => isar.transactionModels.clearSync());
  }
}
