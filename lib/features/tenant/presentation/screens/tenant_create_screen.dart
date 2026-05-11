import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/snackbar_util.dart';

class TenantCreateScreen extends StatefulWidget {
  const TenantCreateScreen({super.key});

  @override
  State<TenantCreateScreen> createState() => _TenantCreateScreenState();
}

class _TenantCreateScreenState extends State<TenantCreateScreen> {
  final _nameController = TextEditingController();
  String _selectedType = 'individual';
  bool _isLoading = false;

  final List<String> _tenantTypes = ['individual', 'family', 'business'];

  Future<void> _createTenant() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      SnackbarUtil.showError(context, 'Please enter a workspace name.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Single RPC call — runs as SECURITY DEFINER, bypasses RLS safely
      await Supabase.instance.client.rpc('create_workspace', params: {
        'p_name': name,
        'p_type': _selectedType,
      });

      if (mounted) {
        SnackbarUtil.showSuccess(context, 'Workspace created successfully!');
        context.go('/tenant-selection');
      }
    } catch (e) {
      if (mounted) SnackbarUtil.showError(context, 'Failed to create workspace.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Workspace')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Set up a new workspace for your personal finances, your family, or your business.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Workspace Name',
                hintText: 'e.g., My Personal Finances',
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Workspace Type'),
              items: _tenantTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type[0].toUpperCase() + type.substring(1)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _createTenant,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Create Workspace'),
            ),
          ],
        ),
      ),
    );
  }
}
