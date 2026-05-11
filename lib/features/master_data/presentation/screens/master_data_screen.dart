import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../core/providers/tenant_provider.dart';
import '../providers/master_data_provider.dart';

class MasterDataScreen extends ConsumerWidget {
  const MasterDataScreen({super.key});

  Future<void> _addAccount(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController(text: '0.0');
    String type = 'bank';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (e.g. Chase Checkings)')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'bank', child: Text('Bank')),
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'credit_card', child: Text('Credit Card')),
                ],
                onChanged: (v) => setState(() => type = v!),
              ),
              const SizedBox(height: 16),
              TextField(controller: balanceCtrl, decoration: const InputDecoration(labelText: 'Starting Balance'), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final balance = double.tryParse(balanceCtrl.text) ?? 0.0;
                final tenantId = ref.read(activeTenantIdProvider);
                try {
                  await Supabase.instance.client.from('accounts').insert({
                    'tenant_id': tenantId,
                    'name': nameCtrl.text,
                    'type': type,
                    'balance': balance,
                    'currency': 'USD'
                  });
                  ref.invalidate(accountsProvider);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    SnackbarUtil.showSuccess(ctx, 'Account added.');
                  }
                } catch (e) {
                  if (ctx.mounted) SnackbarUtil.showError(ctx, 'Failed to add account.');
                }
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _addCategory(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    String type = 'expense';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (e.g. Groceries)')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'expense', child: Text('Expense')),
                  DropdownMenuItem(value: 'income', child: Text('Income')),
                ],
                onChanged: (v) => setState(() => type = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final tenantId = ref.read(activeTenantIdProvider);
                try {
                  await Supabase.instance.client.from('categories').insert({
                    'tenant_id': tenantId,
                    'name': nameCtrl.text,
                    'type': type,
                  });
                  ref.invalidate(categoriesProvider);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    SnackbarUtil.showSuccess(ctx, 'Category added.');
                  }
                } catch (e) {
                  if (ctx.mounted) SnackbarUtil.showError(ctx, 'Failed to add category.');
                }
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Master Data')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Accounts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add), onPressed: () => _addAccount(context, ref)),
            ],
          ),
          accountsAsync.when(
            data: (accounts) => Column(
              children: accounts.map((a) => ListTile(
                leading: const Icon(Icons.account_balance),
                title: Text(a.name),
                subtitle: Text(a.type),
                trailing: Text('\$${a.balance}'),
              )).toList(),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (e, s) => Text('Error: $e'),
          ),
          const Divider(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add), onPressed: () => _addCategory(context, ref)),
            ],
          ),
          categoriesAsync.when(
            data: (categories) => Column(
              children: categories.map((c) => ListTile(
                leading: Icon(c.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward),
                title: Text(c.name),
                subtitle: Text(c.type),
              )).toList(),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (e, s) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}
