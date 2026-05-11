import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../core/providers/tenant_provider.dart';

class TenantSelectionScreen extends ConsumerStatefulWidget {
  const TenantSelectionScreen({super.key});

  @override
  ConsumerState<TenantSelectionScreen> createState() => _TenantSelectionScreenState();
}

class _TenantSelectionScreenState extends ConsumerState<TenantSelectionScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _tenants = [];

  @override
  void initState() {
    super.initState();
    _fetchTenants();
  }

  Future<void> _fetchTenants() async {
    setState(() => _isLoading = true);
    try {
      // Due to RLS, selecting from tenants will only return tenants the user is a member of
      final response = await Supabase.instance.client
          .from('tenants')
          .select('id, name, type');
      
      if (mounted) {
        setState(() {
          _tenants = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });

        if (_tenants.isEmpty) {
          SnackbarUtil.showInfo(context, 'You do not belong to any workspace. Please create one.');
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtil.showError(context, 'Failed to load workspaces.');
        setState(() => _isLoading = false);
      }
    }
  }

  void _selectTenant(String tenantId) {
    ref.read(activeTenantIdProvider.notifier).state = tenantId;
    context.go('/dashboard');
    SnackbarUtil.showSuccess(context, 'Workspace loaded successfully.');
  }

  Future<void> _createTenant() async {
    // Navigate to tenant creation flow
    context.push('/tenant-create');
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Workspace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tenants.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.business_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No workspaces found.', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _createTenant,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Workspace'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tenants.length,
                  itemBuilder: (context, index) {
                    final tenant = _tenants[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(tenant['name'][0].toUpperCase()),
                        ),
                        title: Text(tenant['name']),
                        subtitle: Text('Type: ${tenant['type']}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _selectTenant(tenant['id']),
                      ),
                    );
                  },
                ),
      floatingActionButton: _tenants.isNotEmpty
          ? FloatingActionButton(
              onPressed: _createTenant,
              child: const Icon(Icons.add),
              tooltip: 'New Workspace',
            )
          : null,
    );
  }
}
