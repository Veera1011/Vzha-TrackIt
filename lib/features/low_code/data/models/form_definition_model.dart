class FormDefinitionModel {
  final String id;
  final String tenantId;
  final String name;
  final String description;
  final Map<String, dynamic> schema; // JSON representing fields

  FormDefinitionModel({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.description,
    required this.schema,
  });

  factory FormDefinitionModel.fromJson(Map<String, dynamic> json) {
    return FormDefinitionModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      name: json['name'],
      description: json['description'] ?? '',
      schema: json['schema'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'description': description,
      'schema': schema,
    };
  }
}
