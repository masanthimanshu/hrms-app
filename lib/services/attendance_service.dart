import "dart:convert";
import "dart:math";

import "package:hive_flutter/hive_flutter.dart";

import "/models/attendance_model.dart";

class AttendanceService {
  Box? get _box => Hive.isBoxOpen("myBox") ? Hive.box("myBox") : null;

  static const String _attendanceStorageKey = "attendance_records";

  /// Retrieve all attendance logs
  List<AttendanceModel> getAttendanceLogs() {
    try {
      final raw = _box?.get(_attendanceStorageKey);
      if (raw != null) {
        final List<dynamic> decoded = jsonDecode(raw.toString());
        return decoded
            .map((e) => AttendanceModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}

    // Initial default seed logs for rich UI
    final now = DateTime.now();
    return [
      AttendanceModel(
        id: "att-101",
        userId: "u-01",
        userName: "Alex Vance",
        storeName: "Headquarters - San Francisco",
        latitude: "37.7892",
        longitude: "-122.3982",
        timestamp: now.subtract(const Duration(hours: 4, minutes: 12)),
        isVerified: true,
      ),
      AttendanceModel(
        id: "att-100",
        userId: "u-01",
        userName: "Alex Vance",
        storeName: "Headquarters - San Francisco",
        latitude: "37.7890",
        longitude: "-122.3985",
        timestamp: now.subtract(const Duration(days: 1, hours: 5)),
        isVerified: true,
      ),
    ];
  }

  /// Record new attendance check-in
  Future<AttendanceModel> recordAttendance({
    required String userId,
    String? userName,
    String? storeId,
    String? storeName,
    required String latitude,
    required String longitude,
    String? imageUrl,
    bool isVerified = true,
  }) async {
    final newRecord = AttendanceModel(
      id: "att-${DateTime.now().millisecondsSinceEpoch}",
      userId: userId,
      userName: userName,
      storeId: storeId,
      storeName: storeName ?? "Primary Facility",
      latitude: latitude,
      longitude: longitude,
      imageUrl:
          imageUrl ??
          "s3://hrms-assets/proofs/${DateTime.now().millisecondsSinceEpoch}.jpg",
      timestamp: DateTime.now(),
      isVerified: isVerified,
    );

    final currentList = getAttendanceLogs();
    final updatedList = [newRecord, ...currentList];

    final encoded = jsonEncode(updatedList.map((e) => e.toJson()).toList());
    await _box?.put(_attendanceStorageKey, encoded);

    return newRecord;
  }

  /// Calculate distance between two lat/lng coordinates in meters (Haversine formula)
  static double calculateDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742000 * asin(sqrt(a)); // 2 * R * 1000 meters
  }
}
