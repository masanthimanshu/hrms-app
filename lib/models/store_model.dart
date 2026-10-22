class StoreModel {
  final String id;
  final String name;
  final String address;
  final String latitude;
  final String longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StoreModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json["_id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      address: json["address"]?.toString() ?? "",
      latitude: json["latitude"]?.toString() ?? "",
      longitude: json["longitude"]?.toString() ?? "",
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"].toString())
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.tryParse(json["updatedAt"].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }
}
