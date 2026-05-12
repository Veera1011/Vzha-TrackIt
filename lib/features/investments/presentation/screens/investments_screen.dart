import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/investments_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../core/providers/tenant_provider.dart';

class InvestmentsScreen extends ConsumerWidget {
  const InvestmentsScreen({super.key});

  Future<void> _addInvestment(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String type = 'stocks';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Investment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Investment Name (e.g. Apple Stock)'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'stocks', child: Text('Stocks')),
                  DropdownMenuItem(value: 'mf', child: Text('Mutual Funds')),
                  DropdownMenuItem(value: 'sip', child: Text('SIP')),
                  DropdownMenuItem(value: 'gold', child: Text('Gold')),
                  DropdownMenuItem(value: 'crypto', child: Text('Crypto')),
                ],
                onChanged: (v) => setState(() => type = v!),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl,
                decoration: const InputDecoration(labelText: 'Amount Invested'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text) ?? 0.0;
                final tenantId = ref.read(activeTenantIdProvider);
                if (tenantId == null) return;

                try {
                  await Supabase.instance.client.from('investments').insert({
                    'tenant_id': tenantId,
                    'name': nameCtrl.text,
                    'type': type,
                    'amount_invested': amount,
                    'current_value': amount, // Initial current value same as invested
                    'start_date': DateTime.now().toIso8601String(),
                  });
                  ref.invalidate(investmentsProvider);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    SnackbarUtil.showSuccess(ctx, 'Investment added successfully.');
                  }
                } catch (e) {
                  if (ctx.mounted) SnackbarUtil.showError(ctx, 'Failed to add investment.');
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
    final summary = ref.watch(portfolioSummaryProvider);
    final investmentsAsync = ref.watch(investmentsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Portfolio Value', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        '\$${summary.totalCurrentValue.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Invested', style: TextStyle(fontSize: 12)),
                              Text('\$${summary.totalInvested.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Total Returns', style: TextStyle(fontSize: 12)),
                              Text(
                                '${summary.totalProfitLoss >= 0 ? '+' : ''}\$${summary.totalProfitLoss.toStringAsFixed(2)} (${summary.totalProfitLossPercentage.toStringAsFixed(2)}%)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: summary.totalProfitLoss >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/sip-calculator'),
                      icon: const Icon(Icons.calculate),
                      label: const Text('SIP Calc'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/emi-calculator'),
                      icon: const Icon(Icons.home_work),
                      label: const Text('EMI Calc'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Your Holdings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          investmentsAsync.when(
            data: (investments) {
              if (investments.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('No investments added yet.'),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final inv = investments[index];
                    final isProfit = inv.profitLoss >= 0;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          inv.type == 'stocks' ? Icons.show_chart :
                          inv.type == 'crypto' ? Icons.currency_bitcoin :
                          inv.type == 'gold' ? Icons.monetization_on :
                          Icons.account_balance,
                        ),
                      ),
                      title: Text(inv.name),
                      subtitle: Text('${inv.type.toUpperCase()} • ${inv.startDate.toLocal()}'.split(' ')[0]),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${inv.currentValue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${isProfit ? '+' : ''}\$${inv.profitLoss.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: isProfit ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: investments.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, s) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addInvestment(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
