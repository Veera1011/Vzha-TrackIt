import 'dart:math';
import 'package:flutter/material.dart';

class SIPCalculatorScreen extends StatefulWidget {
  const SIPCalculatorScreen({super.key});

  @override
  State<SIPCalculatorScreen> createState() => _SIPCalculatorScreenState();
}

class _SIPCalculatorScreenState extends State<SIPCalculatorScreen> {
  final _amountCtrl = TextEditingController(text: '5000');
  final _yearsCtrl = TextEditingController(text: '10');
  final _rateCtrl = TextEditingController(text: '12');

  double _investedAmount = 0;
  double _estimatedReturns = 0;
  double _totalValue = 0;

  @override
  void initState() {
    super.initState();
    _calculateSIP();
  }

  void _calculateSIP() {
    final P = double.tryParse(_amountCtrl.text) ?? 0;
    final n = (double.tryParse(_yearsCtrl.text) ?? 0) * 12; // total months
    final i = (double.tryParse(_rateCtrl.text) ?? 0) / 100 / 12; // monthly rate

    if (P > 0 && n > 0 && i > 0) {
      // SIP Formula: M = P × ({[1 + i]^n - 1} / i) × (1 + i)
      final M = P * ((pow(1 + i, n) - 1) / i) * (1 + i);
      
      setState(() {
        _investedAmount = P * n;
        _totalValue = M;
        _estimatedReturns = _totalValue - _investedAmount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SIP Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Monthly Investment (₹/\$)', prefixText: '₹'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateSIP(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _yearsCtrl,
              decoration: const InputDecoration(labelText: 'Investment Period (Years)'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateSIP(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rateCtrl,
              decoration: const InputDecoration(labelText: 'Expected Return Rate (%)'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateSIP(),
            ),
            const SizedBox(height: 32),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text('Total Value', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '₹${_totalValue.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Invested Amount'),
                        Text('₹${_investedAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Est. Returns'),
                        Text('₹${_estimatedReturns.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
