import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transactions_provider.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(transactionsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const TabBar(
          tabs: [
            Tab(text: 'Expenses', icon: Icon(Icons.arrow_upward)),
            Tab(text: 'Income', icon: Icon(Icons.arrow_downward)),
          ],
        ),
        body: transactionsAsyncValue.when(
          data: (transactions) {
            final expenses = transactions.where((t) => t.type == 'expense').toList();
            final income = transactions.where((t) => t.type == 'income').toList();

            return TabBarView(
              children: [
                _TransactionList(transactions: expenses),
                _TransactionList(transactions: income),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/add-transaction'),
          label: const Text('Add'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _TransactionList extends ConsumerWidget {
  final List<TransactionModel> transactions;
  const _TransactionList({required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No records found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isIncome = tx.type == 'income';

        return Dismissible(
          key: Key(tx.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            deleteTransaction(ref, tx.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction deleted')),
            );
          },
          child: InkWell(
            onTap: () => context.push('/add-transaction', extra: tx),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isIncome ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isIncome ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.description.isNotEmpty ? tx.description : 'Transaction',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '${tx.date.toLocal()}'.split(' ')[0],
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
