class AttendanceModel {
  final String id;
  final String? userId;
  final String? storeName;
  final String latitude;
  final String longitude;
  final String? distance;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isVerified;

  const AttendanceModel({
    required this.id,
    this.userId,
    this.storeName,
    required this.latitude,
    required this.longitude,
    this.distance,
    this.imageUrl,
    required this.timestamp,
    this.isVerified = true,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    final dist = json["distance"]?.toString();
    final verified = json["isVerified"] is bool
        ? json["isVerified"] as bool
        : (dist == null || (double.tryParse(dist) ?? 0) <= 1000);

    return AttendanceModel(
      id: json["_id"]?.toString() ?? json["id"]?.toString() ?? "",
      userId: json["userId"]?.toString(),
      storeName: json["storeName"]?.toString(),
      latitude: json["latitude"]?.toString() ?? "0.0",
      longitude: json["longitude"]?.toString() ?? "0.0",
      distance: dist,
      imageUrl: json["imageUrl"]?.toString(),
      timestamp:
          DateTime.tryParse(
            json["createdAt"]?.toString() ??
                json["timestamp"]?.toString() ??
                "",
          )?.toLocal() ??
          DateTime.now(),
      isVerified: verified,
    );
  }

  AttendanceModel copyWith({
    String? id,
    String? userId,
    String? storeName,
    String? latitude,
    String? longitude,
    String? distance,
    String? imageUrl,
    DateTime? timestamp,
    bool? isVerified,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      storeName: storeName ?? this.storeName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
