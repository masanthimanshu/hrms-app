class UserModel {
  final String id;
  final String name;
  final String email;
  final String storeId;
  final bool isValid;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.storeId,
    this.isValid = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"]?.toString() ?? json["id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      email: json["email"]?.toString() ?? "",
      storeId: json["storeId"]?.toString() ?? "",
      isValid: json["isValid"] is bool ? json["isValid"] as bool : true,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? storeId,
    bool? isValid,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      storeId: storeId ?? this.storeId,
      isValid: isValid ?? this.isValid,
    );
  }
}
