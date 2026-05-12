import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/tenant_provider.dart';
import '../../data/models/transaction_model.dart';

final transactionsProvider = FutureProvider<List<TransactionModel>>((ref) async {
  final tenantId = ref.watch(activeTenantIdProvider);
  if (tenantId == null) return [];

  final response = await Supabase.instance.client
      .from('transactions')
      .select()
      .eq('tenant_id', tenantId)
      .order('date', ascending: false);

  return (response as List).map((json) => TransactionModel.fromJson(json)).toList();
});

Future<void> deleteTransaction(WidgetRef ref, String id) async {
  await Supabase.instance.client
      .from('transactions')
      .delete()
      .eq('id', id);
  
  ref.invalidate(transactionsProvider);
}
