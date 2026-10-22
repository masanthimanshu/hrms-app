class AttendanceModel {
  final String id;
  final String userId;
  final String? userName;
  final String? storeId;
  final String? storeName;
  final String latitude;
  final String longitude;
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
    this.imageUrl,
    required this.timestamp,
    this.isVerified = true,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json["_id"]?.toString() ?? json["id"]?.toString() ?? "",
      userId: json["userId"]?.toString() ?? "",
      userName: json["userName"]?.toString(),
      storeId: json["storeId"]?.toString(),
      storeName: json["storeName"]?.toString(),
      latitude: json["latitude"]?.toString() ?? "0.0",
      longitude: json["longitude"]?.toString() ?? "0.0",
      imageUrl: json["imageUrl"]?.toString(),
      timestamp: json["timestamp"] != null
          ? DateTime.tryParse(json["timestamp"].toString()) ?? DateTime.now()
          : (json["createdAt"] != null
              ? DateTime.tryParse(json["createdAt"].toString()) ?? DateTime.now()
              : DateTime.now()),
      isVerified: json["isVerified"] == null ? true : (json["isVerified"] == true),
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
      "imageUrl": imageUrl,
      "timestamp": timestamp.toIso8601String(),
      "isVerified": isVerified,
    };
  }
}
