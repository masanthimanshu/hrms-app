class UserModel {
  final String id;
  final String name;
  final String email;
  final String storeId;
  final bool isValid;
  final String? storeName;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.storeId,
    this.isValid = true,
    this.storeName,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"]?.toString() ?? json["id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      email: json["email"]?.toString() ?? "",
      storeId: json["storeId"]?.toString() ?? "",
      isValid: json["isValid"] == null ? true : (json["isValid"] == true),
      storeName: json["storeName"]?.toString(),
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "email": email,
      "storeId": storeId,
      "isValid": isValid,
      "storeName": storeName,
      "createdAt": createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? storeId,
    bool? isValid,
    String? storeName,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      storeId: storeId ?? this.storeId,
      isValid: isValid ?? this.isValid,
      storeName: storeName ?? this.storeName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
