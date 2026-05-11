import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../core/providers/tenant_provider.dart';
import '../../../master_data/presentation/providers/master_data_provider.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transactions_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? transaction;
  const AddTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _descController;
  late String _type;
  String? _selectedAccountId;
  String? _selectedCategoryId;
  late DateTime _selectedDate;
  bool _isLoading = false;
  XFile? _receiptImage;
  String? _receiptUrl;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _amountController = TextEditingController(text: tx?.amount.toString() ?? '');
    _descController = TextEditingController(text: tx?.description ?? '');
    _type = tx?.type ?? 'expense';
    _selectedAccountId = tx?.accountId;
    _selectedCategoryId = tx?.categoryId;
    _selectedDate = tx?.date ?? DateTime.now();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() => _receiptImage = image);
    }
  }

  Future<void> _submit() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty || _selectedAccountId == null || _selectedCategoryId == null) {
      SnackbarUtil.showError(context, 'Please fill in amount, account, and category.');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      SnackbarUtil.showError(context, 'Please enter a valid amount.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final tenantId = ref.read(activeTenantIdProvider);
      final userId = Supabase.instance.client.auth.currentUser?.id;

      // 1. Upload Image if present
      if (_receiptImage != null) {
        final bytes = await _receiptImage!.readAsBytes();
        final fileExt = _receiptImage!.name.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = '$tenantId/$fileName';

        await Supabase.instance.client.storage
            .from('receipts')
            .uploadBinary(filePath, bytes);
        
        _receiptUrl = Supabase.instance.client.storage
            .from('receipts')
            .getPublicUrl(filePath);
      }

      final data = {
        'tenant_id': tenantId,
        'account_id': _selectedAccountId,
        'category_id': _selectedCategoryId,
        'amount': amount,
        'type': _type,
        'date': _selectedDate.toIso8601String(),
        'description': _descController.text.trim(),
        'created_by': userId,
        'status': 'completed',
        if (_receiptUrl != null) 'receipt_url': _receiptUrl,
      };

      if (widget.transaction != null) {
        // Update existing
        await Supabase.instance.client
            .from('transactions')
            .update(data)
            .eq('id', widget.transaction!.id);
      } else {
        // Insert new
        await Supabase.instance.client.from('transactions').insert(data);
      }

      // Invalidate to refresh the list
      ref.invalidate(transactionsProvider);

      if (mounted) {
        SnackbarUtil.showSuccess(context, widget.transaction != null ? 'Transaction updated.' : 'Transaction added.');
        context.pop();
      }
    } catch (e) {
      if (mounted) SnackbarUtil.showError(context, 'Failed to save transaction.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.transaction != null ? 'Edit Transaction' : 'Add Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Expense'), icon: Icon(Icons.arrow_upward)),
                ButtonSegment(value: 'income', label: Text('Income'), icon: Icon(Icons.arrow_downward)),
              ],
              selected: {_type},
              onSelectionChanged: (set) => setState(() {
                _type = set.first;
                _selectedCategoryId = null; // Clear category when switching type
              }),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            accountsAsync.when(
              data: (accounts) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Account'),
                value: _selectedAccountId,
                items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                onChanged: (val) => setState(() => _selectedAccountId = val),
              ),
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (e, s) => Text('Error loading accounts: $e'),
            ),
            const SizedBox(height: 16),
            categoriesAsync.when(
              data: (categories) {
                final filtered = categories.where((c) => c.type == _type).toList();
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  value: _selectedCategoryId,
                  items: filtered.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                );
              },
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (e, s) => Text('Error loading categories: $e'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date'),
              subtitle: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12)
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description (Optional)'),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Attach Receipt'),
              subtitle: Text(_receiptImage != null ? 'Image selected' : 'Optional'),
              trailing: _receiptImage != null ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.upload_file),
              onTap: _pickImage,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12)
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(widget.transaction != null ? 'Update Transaction' : 'Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
