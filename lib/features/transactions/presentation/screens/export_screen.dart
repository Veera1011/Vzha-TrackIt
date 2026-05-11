import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();

  Future<void> _exportPdf(List<TransactionModel> transactions) async {
    final filtered = _filterTransactions(transactions);

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Text('Vzha TrackIt — Transaction Report',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text(
              'Period: ${_from.toLocal().toString().split(' ')[0]} – ${_to.toLocal().toString().split(' ')[0]}'),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Type', 'Description', 'Amount'],
            data: filtered.map((t) => [
              t.date.toLocal().toString().split(' ')[0],
              t.type.toUpperCase(),
              t.description.isEmpty ? '—' : t.description,
              '\$${t.amount.toStringAsFixed(2)}',
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal200),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 16),
          _buildSummaryRow(filtered),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  pw.Widget _buildSummaryRow(List<TransactionModel> transactions) {
    final income = transactions.where((t) => t.type == 'income').fold(0.0, (s, t) => s + t.amount);
    final expenses = transactions.where((t) => t.type == 'expense').fold(0.0, (s, t) => s + t.amount);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Text('Total Income: \$${income.toStringAsFixed(2)}', style: pw.TextStyle(color: PdfColors.green700)),
          pw.Text('Total Expense: \$${expenses.toStringAsFixed(2)}', style: pw.TextStyle(color: PdfColors.red700)),
          pw.Text('Net Balance: \$${(income - expenses).toStringAsFixed(2)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ]),
      ],
    );
  }

  Future<void> _exportCsv(List<TransactionModel> transactions) async {
    final filtered = _filterTransactions(transactions);
    final buffer = StringBuffer();
    buffer.writeln('Date,Type,Description,Amount,Status');
    for (final t in filtered) {
      buffer.writeln(
          '${t.date.toLocal().toString().split(' ')[0]},${t.type},"${t.description}",${t.amount},${t.status}');
    }

    final bytes = buffer.toString().codeUnits;
    await Printing.sharePdf(
      bytes: Uint8List.fromList(bytes),
      filename: 'vzha_transactions.csv',
    );
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> all) {
    return all.where((t) {
      final d = t.date;
      return d.isAfter(_from.subtract(const Duration(seconds: 1))) &&
          d.isBefore(_to.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Export Report')),
      body: txAsync.when(
        data: (transactions) {
          final filtered = _filterTransactions(transactions);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select Date Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: const Text('From'),
                                subtitle: Text(_from.toLocal().toString().split(' ')[0]),
                                trailing: const Icon(Icons.calendar_today),
                                onTap: () async {
                                  final d = await showDatePicker(context: context, initialDate: _from, firstDate: DateTime(2020), lastDate: DateTime.now());
                                  if (d != null) setState(() => _from = d);
                                },
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: const Text('To'),
                                subtitle: Text(_to.toLocal().toString().split(' ')[0]),
                                trailing: const Icon(Icons.calendar_today),
                                onTap: () async {
                                  final d = await showDatePicker(context: context, initialDate: _to, firstDate: DateTime(2020), lastDate: DateTime.now());
                                  if (d != null) setState(() => _to = d);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '${filtered.length} transactions found in this period',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: filtered.isEmpty ? null : () => _exportPdf(transactions),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export as PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: filtered.isEmpty ? null : () => _exportCsv(transactions),
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Export as CSV'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
