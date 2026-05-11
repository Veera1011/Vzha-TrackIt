import 'dart:math';
import 'package:flutter/material.dart';

class EMICalculatorScreen extends StatefulWidget {
  const EMICalculatorScreen({super.key});

  @override
  State<EMICalculatorScreen> createState() => _EMICalculatorScreenState();
}

class _EMICalculatorScreenState extends State<EMICalculatorScreen> {
  final _principalCtrl = TextEditingController(text: '100000');
  final _rateCtrl = TextEditingController(text: '10.5');
  final _tenureCtrl = TextEditingController(text: '5');

  double _emi = 0;
  double _totalInterest = 0;
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _calculateEMI();
  }

  void _calculateEMI() {
    final P = double.tryParse(_principalCtrl.text) ?? 0;
    final R = (double.tryParse(_rateCtrl.text) ?? 0) / 12 / 100;
    final N = (double.tryParse(_tenureCtrl.text) ?? 0) * 12;

    if (P > 0 && R > 0 && N > 0) {
      // EMI = P x R x (1+R)^N / [(1+R)^N-1]
      final emi = P * R * (pow(1 + R, N)) / (pow(1 + R, N) - 1);
      
      setState(() {
        _emi = emi;
        _totalAmount = emi * N;
        _totalInterest = _totalAmount - P;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EMI Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _principalCtrl,
              decoration: const InputDecoration(labelText: 'Loan Amount', prefixText: '₹'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateEMI(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rateCtrl,
              decoration: const InputDecoration(labelText: 'Interest Rate (%)'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateEMI(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tenureCtrl,
              decoration: const InputDecoration(labelText: 'Loan Tenure (Years)'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateEMI(),
            ),
            const SizedBox(height: 32),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text('Monthly EMI', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '₹${_emi.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Principal Amount'),
                        Text('₹${(_totalAmount - _totalInterest).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Interest'),
                        Text('₹${_totalInterest.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount Payable'),
                        Text('₹${_totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
