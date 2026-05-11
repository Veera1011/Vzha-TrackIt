import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/tenant_provider.dart';
import '../../data/models/account_model.dart';
import '../../data/models/category_model.dart';

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final tenantId = ref.watch(activeTenantIdProvider);
  if (tenantId == null) return [];

  final response = await Supabase.instance.client
      .from('categories')
      .select()
      .eq('tenant_id', tenantId)
      .order('name', ascending: true);

  return (response as List)
      .map((json) => CategoryModel.fromJson(json))
      .toList();
});

final accountsProvider = FutureProvider<List<AccountModel>>((ref) async {
  final tenantId = ref.watch(activeTenantIdProvider);
  if (tenantId == null) return [];

  final response = await Supabase.instance.client
      .from('accounts')
      .select()
      .eq('tenant_id', tenantId)
      .order('name', ascending: true);

  return (response as List).map((json) => AccountModel.fromJson(json)).toList();
});
