class AttendanceModel {
  final String id;
  final String userId;
  final String? userName;
  final String? storeId;
  final String? storeName;
  final String latitude;
  final String longitude;
  final String? distance;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isVerified;

  const AttendanceModel({
    required this.id,
    required this.userId,
    this.userName,
    this.storeId,
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
    final verifiedVal = json["isVerified"];
    final verified = verifiedVal is bool
        ? verifiedVal
        : (dist == null || (double.tryParse(dist) ?? 0) <= 1000);

    return AttendanceModel(
      id: json["_id"]?.toString() ?? json["id"]?.toString() ?? "",
      userId: json["userId"]?.toString() ?? "",
      userName: json["userName"]?.toString(),
      storeId: json["storeId"]?.toString(),
      storeName: json["storeName"]?.toString(),
      latitude: json["latitude"]?.toString() ?? "0.0",
      longitude: json["longitude"]?.toString() ?? "0.0",
      distance: dist,
      imageUrl: json["imageUrl"]?.toString(),
      timestamp:
          DateTime.tryParse(
            json["createdAt"]?.toString() ??
                json["timestamp"]?.toString() ??
                json["updatedAt"]?.toString() ??
                "",
          ) ??
          DateTime.now(),
      isVerified: verified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "userId": userId,
      "userName": userName,
      "storeId": storeId,
      "storeName": storeName,
      "latitude": latitude,
      "longitude": longitude,
      "distance": distance,
      "imageUrl": imageUrl,
      "timestamp": timestamp.toIso8601String(),
      "isVerified": isVerified,
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? storeId,
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
      userName: userName ?? this.userName,
      storeId: storeId ?? this.storeId,
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
