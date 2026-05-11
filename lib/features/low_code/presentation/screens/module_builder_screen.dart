import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/tenant_provider.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../providers/low_code_provider.dart';

class ModuleBuilderScreen extends ConsumerStatefulWidget {
  const ModuleBuilderScreen({super.key});

  @override
  ConsumerState<ModuleBuilderScreen> createState() => _ModuleBuilderScreenState();
}

class _ModuleBuilderScreenState extends ConsumerState<ModuleBuilderScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final List<Map<String, dynamic>> _fields = [];
  bool _isLoading = false;

  void _addField() {
    setState(() {
      _fields.add({
        'name': 'field_${_fields.length + 1}',
        'label': 'New Field',
        'type': 'text',
        'required': false,
      });
    });
  }

  Future<void> _saveModule() async {
    if (_nameController.text.isEmpty) {
      SnackbarUtil.showError(context, 'Please enter a module name');
      return;
    }
    if (_fields.isEmpty) {
      SnackbarUtil.showError(context, 'Please add at least one field');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final tenantId = ref.read(activeTenantIdProvider);
      await Supabase.instance.client.from('form_definitions').insert({
        'tenant_id': tenantId,
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'schema': {'fields': _fields},
      });

      if (mounted) {
        SnackbarUtil.showSuccess(context, 'Module created successfully!');
        ref.invalidate(formsProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) SnackbarUtil.showError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Custom Module'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveModule,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Module Name', hintText: 'e.g., Inventory, Projects'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fields', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(onPressed: _addField, icon: const Icon(Icons.add), label: const Text('Add Field')),
              ],
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _fields.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(labelText: 'Field Label (Display Name)'),
                                onChanged: (v) {
                                  setState(() {
                                    _fields[index]['label'] = v;
                                    // Auto-generate name from label if not edited
                                    _fields[index]['name'] = v.toLowerCase().replaceAll(' ', '_');
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setState(() => _fields.removeAt(index)),
                            ),
                          ],
                        ),
                        TextField(
                          decoration: const InputDecoration(labelText: 'Internal Name (Key)'),
                          controller: TextEditingController(text: _fields[index]['name']),
                          onChanged: (v) => _fields[index]['name'] = v,
                        ),
                        DropdownButton<String>(
                          value: _fields[index]['type'],
                          isExpanded: true,
                          items: ['text', 'number', 'date', 'select']
                              .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                              .toList(),
                          onChanged: (v) => setState(() => _fields[index]['type'] = v),
                        ),
                        SwitchListTile(
                          title: const Text('Required'),
                          value: _fields[index]['required'],
                          onChanged: (v) => setState(() => _fields[index]['required'] = v),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
