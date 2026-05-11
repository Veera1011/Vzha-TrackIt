import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';

class DashboardSummary {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final Map<int, double> last7DaysIncome;
  final Map<int, double> last7DaysExpense;

  DashboardSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.last7DaysIncome,
    required this.last7DaysExpense,
  });
}

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final transactionsAsyncValue = ref.watch(transactionsProvider);

  return transactionsAsyncValue.maybeWhen(
    data: (transactions) {
      double income = 0;
      double expenses = 0;
      Map<int, double> dailyIncome = {for (var i = 0; i < 7; i++) i: 0.0};
      Map<int, double> dailyExpense = {for (var i = 0; i < 7; i++) i: 0.0};
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (var tx in transactions) {
        if (tx.type == 'income') {
          income += tx.amount;
        } else if (tx.type == 'expense') {
          expenses += tx.amount;
        }
        
        // Calculate days ago
        final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
        final daysAgo = today.difference(txDate).inDays;
        
        if (daysAgo >= 0 && daysAgo < 7) {
          if (tx.type == 'income') {
            dailyIncome[daysAgo] = (dailyIncome[daysAgo] ?? 0) + tx.amount;
          } else if (tx.type == 'expense') {
            dailyExpense[daysAgo] = (dailyExpense[daysAgo] ?? 0) + tx.amount;
          }
        }
      }

      return DashboardSummary(
        totalBalance: income - expenses,
        totalIncome: income,
        totalExpenses: expenses,
        last7DaysIncome: dailyIncome,
        last7DaysExpense: dailyExpense,
      );
    },
    orElse: () => DashboardSummary(
      totalBalance: 0, 
      totalIncome: 0, 
      totalExpenses: 0,
      last7DaysIncome: {for (var i = 0; i < 7; i++) i: 0.0},
      last7DaysExpense: {for (var i = 0; i < 7; i++) i: 0.0},
    ),
  );
});
