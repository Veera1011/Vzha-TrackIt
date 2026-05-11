class InvestmentModel {
  final String id;
  final String tenantId;
  final String name;
  final String type; // stocks, mf, sip, gold, crypto
  final double amountInvested;
  final double currentValue;
  final DateTime startDate;

  InvestmentModel({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.type,
    required this.amountInvested,
    required this.currentValue,
    required this.startDate,
  });

  factory InvestmentModel.fromJson(Map<String, dynamic> json) {
    return InvestmentModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      name: json['name'],
      type: json['type'],
      amountInvested: double.parse(json['amount_invested'].toString()),
      currentValue: double.parse((json['current_value'] ?? json['amount_invested']).toString()),
      startDate: DateTime.parse(json['start_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'type': type,
      'amount_invested': amountInvested,
      'current_value': currentValue,
      'start_date': "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
    };
  }

  double get profitLoss => currentValue - amountInvested;
  double get profitLossPercentage => (amountInvested > 0) ? (profitLoss / amountInvested) * 100 : 0;
}
