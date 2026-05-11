import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/tenant_provider.dart';
import '../../../../core/database/isar_service.dart';
import '../../data/models/transaction_model.dart';

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

final transactionsProvider = FutureProvider<List<TransactionModel>>((ref) async {
  final tenantId = ref.watch(activeTenantIdProvider);
  if (tenantId == null) return [];

  try {
    final response = await Supabase.instance.client
        .from('transactions')
        .select()
        .eq('tenant_id', tenantId)
        .order('date', ascending: false);

    final transactions = (response as List).map((json) => TransactionModel.fromJson(json)).toList();
    
    // Save to local Isar cache only if NOT on web
    if (!kIsWeb) {
      final isar = ref.read(isarServiceProvider);
      await isar.saveTransactions(transactions);
    }

    return transactions;
  } catch (e) {
    // Fallback to local cache only if NOT on web
    if (!kIsWeb) {
      final isar = ref.read(isarServiceProvider);
      return await isar.getTransactions(tenantId);
    }
    rethrow;
  }
});
