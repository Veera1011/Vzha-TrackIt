class TransactionModel {
  final String id;
  
  final String tenantId;
  
  final String? accountId;
  final String? categoryId;
  final double amount;
  final String type;
  final DateTime date;
  final String description;
  final String status;

  TransactionModel({
    required this.id,
    required this.tenantId,
    this.accountId,
    this.categoryId,
    required this.amount,
    required this.type,
    required this.date,
    required this.description,
    required this.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      accountId: json['account_id'],
      categoryId: json['category_id'],
      amount: double.parse(json['amount'].toString()),
      type: json['type'],
      date: DateTime.parse(json['date']),
      description: json['description'] ?? '',
      status: json['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
      'description': description,
      'status': status,
    };
  }
}
