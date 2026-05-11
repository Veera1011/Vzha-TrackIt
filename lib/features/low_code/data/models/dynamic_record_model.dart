class DynamicRecordModel {
  final String id;
  final String tenantId;
  final String formId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final String createdBy;

  DynamicRecordModel({
    required this.id,
    required this.tenantId,
    required this.formId,
    required this.data,
    required this.createdAt,
    required this.createdBy,
  });

  factory DynamicRecordModel.fromJson(Map<String, dynamic> json) {
    return DynamicRecordModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      formId: json['form_id'],
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'form_id': formId,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
    };
  }
}
