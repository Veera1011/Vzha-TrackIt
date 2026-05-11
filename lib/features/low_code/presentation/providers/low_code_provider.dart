import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/tenant_provider.dart';
import '../../data/models/form_definition_model.dart';
import '../../data/models/dynamic_record_model.dart';

final formsProvider = FutureProvider<List<FormDefinitionModel>>((ref) async {
  final tenantId = ref.watch(activeTenantIdProvider);
  if (tenantId == null) return [];

  final response = await Supabase.instance.client
      .from('form_definitions')
      .select()
      .eq('tenant_id', tenantId)
      .order('created_at', ascending: false);

  return (response as List).map((json) => FormDefinitionModel.fromJson(json)).toList();
});

final recordsProvider = FutureProvider.family<List<DynamicRecordModel>, String>((ref, formId) async {
  final tenantId = ref.watch(activeTenantIdProvider);
  if (tenantId == null) return [];

  final response = await Supabase.instance.client
      .from('dynamic_records')
      .select()
      .eq('tenant_id', tenantId)
      .eq('form_id', formId)
      .order('created_at', ascending: false);

  return (response as List).map((json) => DynamicRecordModel.fromJson(json)).toList();
});
