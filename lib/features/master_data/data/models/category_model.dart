class CategoryModel {
  final String id;
  final String tenantId;
  final String name;
  final String type;
  final String? icon;
  final String? color;

  CategoryModel({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.type,
    this.icon,
    this.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      name: json['name'],
      type: json['type'],
      icon: json['icon'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
    };
  }
}
