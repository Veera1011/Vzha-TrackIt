import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/tenant_provider.dart';
import '../../../transactions/presentation/screens/transactions_screen.dart';
import '../../../master_data/presentation/providers/master_data_provider.dart';
import '../../../master_data/presentation/screens/master_data_screen.dart';
import '../../../investments/presentation/screens/investments_screen.dart';
import '../../../low_code/presentation/screens/low_code_forms_screen.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    ref.read(activeTenantIdProvider.notifier).state = null;
    if (mounted) context.go('/login');
  }

  void _switchTenant() {
    ref.read(activeTenantIdProvider.notifier).state = null;
    context.go('/tenant-selection');
  }

  @override
  Widget build(BuildContext context) {
    final tenantId = ref.watch(activeTenantIdProvider);
    
    // Safety check: if no tenant is selected, we shouldn't be here
    if (tenantId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/tenant-selection');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = [
      _HomeTab(tenantId: tenantId),
      const TransactionsScreen(),
      const InvestmentsScreen(),
      const MasterDataScreen(),
      const LowCodeFormsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipOval(
            child: Image.asset(
              'assets/images/App_log.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.dashboard),
            ),
          ),
        ),
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Switch Workspace',
            onPressed: _switchTenant,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.trending_up_outlined), selectedIcon: Icon(Icons.trending_up), label: 'Investments'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Master Data'),
          NavigationDestination(icon: Icon(Icons.dynamic_form_outlined), selectedIcon: Icon(Icons.dynamic_form), label: 'Apps'),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  final String tenantId;
  const _HomeTab({required this.tenantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final sym = ref.watch(themeProvider).currencySymbol;
    final categoriesAsync = ref.watch(categoriesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Balance', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    '$sym${summary.totalBalance.toStringAsFixed(2)}', 
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Income', 
                  amount: '$sym${summary.totalIncome.toStringAsFixed(2)}', 
                  icon: Icons.arrow_downward, 
                  color: Colors.green
                )
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: 'Expenses', 
                  amount: '$sym${summary.totalExpenses.toStringAsFixed(2)}', 
                  icon: Icons.arrow_upward, 
                  color: Colors.red
                )
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Last 7 Days', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < 0 || value.toInt() > 6) return const Text('');
                            return Text('${6 - value.toInt()}d', style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (int i = 6; i >= 0; i--)
                            FlSpot((6 - i).toDouble(), summary.last7DaysIncome[i] ?? 0.0)
                        ],
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: true, color: Colors.green.withValues(alpha: 0.1)),
                      ),
                      LineChartBarData(
                        spots: [
                          for (int i = 6; i >= 0; i--)
                            FlSpot((6 - i).toDouble(), summary.last7DaysExpense[i] ?? 0.0)
                        ],
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: true, color: Colors.red.withValues(alpha: 0.1)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 24),
          const Text('Category Spending', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          categoriesAsync.when(
            data: (categories) {
              if (summary.categoryExpenses.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No expenses to show'))));
              
              final sortedCats = summary.categoryExpenses.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              final topCats = sortedCats.take(5).toList();

              return SizedBox(
                height: 250,
                child: Card(
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: topCats.asMap().entries.map((e) {
                              final cat = categories.firstWhere((c) => c.id == e.value.key, orElse: () => categories.first);
                              return PieChartSectionData(
                                color: Colors.primaries[e.key % Colors.primaries.length],
                                value: e.value.value,
                                title: '',
                                radius: 40,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: topCats.asMap().entries.map((e) {
                            final cat = categories.firstWhere((c) => c.id == e.value.key, orElse: () => categories.first);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(width: 12, height: 12, color: Colors.primaries[e.key % Colors.primaries.length]),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(cat.name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                  Text('\$${e.value.value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text('Error: $e'),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: summary.recentTransactions.length,
            itemBuilder: (context, index) {
              final tx = summary.recentTransactions[index];
              final isIncome = tx.type == 'income';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isIncome ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? Colors.green : Colors.red, size: 16),
                ),
                title: Text(tx.description.isNotEmpty ? tx.description : 'Transaction'),
                subtitle: Text('${tx.date.toLocal()}'.split(' ')[0]),
                trailing: Text(
                  '${isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                  style: TextStyle(color: isIncome ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({required this.title, required this.amount, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            Text(amount, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
