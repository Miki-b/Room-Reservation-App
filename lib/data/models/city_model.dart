class CityModel {
  final String id;
  final String name;
  final String countryId;

  CityModel({
    required this.id,
    required this.name,
    required this.countryId,
  });

  factory CityModel.fromMap(Map<String, dynamic> map, String id) {
    return CityModel(
      id: id,
      name: map['name'] ?? '',
      countryId: map['countryId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'countryId': countryId,
    };
  }
}
