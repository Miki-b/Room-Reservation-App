class AmenityModel {
  final String id;
  final String name;
  final String icon;

  AmenityModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory AmenityModel.fromMap(Map<String, dynamic> map, String id) {
    return AmenityModel(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
    };
  }
}
