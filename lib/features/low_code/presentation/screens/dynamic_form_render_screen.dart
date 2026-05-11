import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../core/providers/tenant_provider.dart';
import '../../data/models/form_definition_model.dart';
import '../providers/low_code_provider.dart';

class DynamicFormRenderScreen extends ConsumerStatefulWidget {
  final FormDefinitionModel formDef;

  const DynamicFormRenderScreen({super.key, required this.formDef});

  @override
  ConsumerState<DynamicFormRenderScreen> createState() => _DynamicFormRenderScreenState();
}

class _DynamicFormRenderScreenState extends ConsumerState<DynamicFormRenderScreen> {
  final Map<String, dynamic> _formData = {};
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final tenantId = ref.read(activeTenantIdProvider);
      final userId = Supabase.instance.client.auth.currentUser?.id;

      await Supabase.instance.client.from('dynamic_records').insert({
        'tenant_id': tenantId,
        'form_id': widget.formDef.id,
        'data': _formData,
        'created_by': userId,
      });

      ref.invalidate(recordsProvider(widget.formDef.id));

      if (mounted) {
        SnackbarUtil.showSuccess(context, 'Record saved successfully.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) SnackbarUtil.showError(context, 'Failed to save record.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildField(Map<String, dynamic> field) {
    final name = field['name'] as String;
    final type = field['type'] as String;
    final label = field['label'] as String? ?? name;
    final required = field['required'] as bool? ?? false;

    if (type == 'text' || type == 'number') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
          ),
          keyboardType: type == 'number' ? TextInputType.number : TextInputType.text,
          onChanged: (val) => _formData[name] = type == 'number' ? num.tryParse(val) : val,
        ),
      );
    } else if (type == 'boolean') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SwitchListTile(
          title: Text(label + (required ? ' *' : '')),
          value: _formData[name] ?? false,
          onChanged: (val) {
            setState(() => _formData[name] = val);
          },
        ),
      );
    } else if (type == 'select') {
      final options = (field['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: label + (required ? ' *' : '')),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (val) => _formData[name] = val,
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    // Expected schema format: {"fields": [{"name": "age", "type": "number", "label": "Age"}]}
    final schema = widget.formDef.schema;
    final fields = (schema['fields'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    final recordsAsync = ref.watch(recordsProvider(widget.formDef.id));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.formDef.name),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add), text: 'Add Record'),
              Tab(icon: Icon(Icons.history), text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Form
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('New Entry', style: Theme.of(context).textTheme.titleLarge),
                      const Divider(),
                      const SizedBox(height: 16),
                      if (fields.isEmpty)
                        const Text('No fields defined for this module.')
                      else
                        ...fields.map(_buildField),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading ? const CircularProgressIndicator() : const Text('Submit Record'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Tab 2: Records
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: recordsAsync.when(
                data: (records) {
                  if (records.isEmpty) {
                    return const Center(child: Text('No records found.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return Card(
                        child: ListTile(
                          title: Text(record.data.values.join(' | ')),
                          subtitle: Text('Created: ${record.createdAt.toLocal().toString().split('.')[0]}'),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
