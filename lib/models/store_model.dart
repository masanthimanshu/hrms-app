class StoreModel {
  final String id;
  final String name;
  final String address;
  final String latitude;
  final String longitude;

  const StoreModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json["_id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      address: json["address"]?.toString() ?? "",
      latitude: json["latitude"]?.toString() ?? "",
      longitude: json["longitude"]?.toString() ?? "",
    );
  }
}
