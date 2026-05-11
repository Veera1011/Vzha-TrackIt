import 'package:isar/isar.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id isarId = Isar.autoIncrement;
  
  @Index(unique: true, replace: true)
  final String id;
  
  @Index()
  final String tenantId;
  
  final double amount;
  final String type;
  final DateTime date;
  final String description;
  final String status;

  TransactionModel({
    required this.id,
    required this.tenantId,
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
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
      'description': description,
      'status': status,
    };
  }
}
