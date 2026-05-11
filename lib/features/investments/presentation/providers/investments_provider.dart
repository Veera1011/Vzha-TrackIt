import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/tenant_provider.dart';
import '../../data/models/investment_model.dart';

final investmentsProvider = FutureProvider<List<InvestmentModel>>((ref) async {
  final tenantId = ref.watch(activeTenantIdProvider);
  if (tenantId == null) return [];

  final response = await Supabase.instance.client
      .from('investments')
      .select()
      .eq('tenant_id', tenantId)
      .order('start_date', ascending: false);

  return (response as List).map((json) => InvestmentModel.fromJson(json)).toList();
});

class PortfolioSummary {
  final double totalInvested;
  final double totalCurrentValue;
  
  double get totalProfitLoss => totalCurrentValue - totalInvested;
  double get totalProfitLossPercentage => (totalInvested > 0) ? (totalProfitLoss / totalInvested) * 100 : 0;

  PortfolioSummary({required this.totalInvested, required this.totalCurrentValue});
}

final portfolioSummaryProvider = Provider<PortfolioSummary>((ref) {
  final investmentsAsyncValue = ref.watch(investmentsProvider);

  return investmentsAsyncValue.maybeWhen(
    data: (investments) {
      double invested = 0;
      double current = 0;

      for (var inv in investments) {
        invested += inv.amountInvested;
        current += inv.currentValue;
      }

      return PortfolioSummary(
        totalInvested: invested,
        totalCurrentValue: current,
      );
    },
    orElse: () => PortfolioSummary(totalInvested: 0, totalCurrentValue: 0),
  );
});
