import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/transactions_provider.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(transactionsProvider);

    return Scaffold(
      body: transactionsAsyncValue.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final isIncome = tx.type == 'income';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isIncome ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                  child: Icon(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(tx.description.isNotEmpty ? tx.description : 'Transaction'),
                subtitle: Text(tx.date.toLocal().toString().split(' ')[0]),
                trailing: Text(
                  '${isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading transactions: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-transaction');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
