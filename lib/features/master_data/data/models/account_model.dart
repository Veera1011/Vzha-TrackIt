class AccountModel {
  final String id;
  final String tenantId;
  final String name;
  final String type;
  final double balance;
  final String currency;

  AccountModel({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      name: json['name'],
      type: json['type'],
      balance: double.parse(json['balance'].toString()),
      currency: json['currency'] ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'type': type,
      'balance': balance,
      'currency': currency,
    };
  }
}
