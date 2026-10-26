import "dart:convert";
import "dart:io";
import "dart:math";

import "package:hive_flutter/hive_flutter.dart";

import "/models/attendance_model.dart";
import "/network/api_response.dart";
import "/network/endpoints.dart";
import "/network/requests.dart";

class AttendanceService with HTTPRequests {
  Box? get _box => Hive.isBoxOpen("myBox") ? Hive.box("myBox") : null;
  static const _storageKey = "attendance_records";

  /// Request presigned AWS S3 upload URL from POST /secure/upload/image
  Future<ApiResponse<Map<String, String>>> requestUploadUrl({
    String text = "Attendance selfie verification",
  }) async {
    final res = await postRequest(
      url: apiEndpoint(ApiEndpoints.uploadImage),
      payload: {"text": text},
    );

    final uploadUrl = res?["uploadUrl"]?.toString() ?? res?["url"]?.toString();
    final imageKey =
        res?["key"]?.toString() ??
        res?["imageUrl"]?.toString() ??
        "images/${DateTime.now().millisecondsSinceEpoch}.webp";

    if (uploadUrl != null && uploadUrl.isNotEmpty) {
      return ApiResponse.success({
        "uploadUrl": uploadUrl,
        "imageKey": imageKey,
      });
    }
    return ApiResponse.error(
      res?["message"]?.toString() ?? "Failed to obtain upload URL",
    );
  }

  /// Direct binary upload to AWS S3 using presigned PUT URL
  Future<bool> uploadSelfieToS3({
    required String uploadUrl,
    required String localFilePath,
  }) async {
    try {
      final bytes = await File(localFilePath).readAsBytes();
      return await uploadBinaryToUrl(url: uploadUrl, bytes: bytes);
    } catch (_) {
      return false;
    }
  }

  /// Submit attendance check-in via POST /secure/attendance/add
  Future<ApiResponse<AttendanceModel>> submitAttendance({
    required String latitude,
    required String longitude,
    required String imageUrl,
    String? storeName,
    String? userName,
  }) async {
    final res = await postRequest(
      url: apiEndpoint(ApiEndpoints.attendanceAdd),
      payload: {
        "latitude": latitude,
        "longitude": longitude,
        "imageUrl": imageUrl,
      },
    );

    final dataMap =
        (res?["data"] ?? res?["attendance"] ?? res) as Map<String, dynamic>?;
    if (dataMap != null &&
        (dataMap["_id"] != null ||
            dataMap["id"] != null ||
            dataMap["userId"] != null)) {
      final record = AttendanceModel.fromJson(dataMap).copyWith(
        storeName: storeName ?? dataMap["storeName"]?.toString(),
        userName: userName ?? dataMap["userName"]?.toString(),
      );
      _cacheRecord(record);
      return ApiResponse.success(record, message: res?["message"]?.toString());
    }

    return ApiResponse.error(
      res?["message"]?.toString() ?? "Failed to record attendance",
    );
  }

  /// Fetch all attendance records via GET /secure/attendance/all
  Future<ApiResponse<List<AttendanceModel>>> fetchAllAttendance({
    String? fallbackStoreName,
  }) async {
    final res = await getRequest(apiEndpoint(ApiEndpoints.attendanceAll));
    final rawList = res?["data"] ?? res?["attendance"];

    if (rawList is List) {
      final records = rawList.map((item) {
        final rec = AttendanceModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
        return rec.storeName == null && fallbackStoreName != null
            ? rec.copyWith(storeName: fallbackStoreName)
            : rec;
      }).toList();

      records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _saveAllToCache(records);
      return ApiResponse.success(records);
    }

    return ApiResponse.error(
      res?["message"]?.toString() ?? "No attendance records found",
    );
  }

  /// Cached records for offline & instant initial display
  List<AttendanceModel> getCachedAttendanceLogs() {
    try {
      final raw = _box?.get(_storageKey);
      if (raw != null) {
        final List<dynamic> decoded = jsonDecode(raw.toString());
        return decoded
            .map((e) => AttendanceModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  void _cacheRecord(AttendanceModel record) {
    final cached = getCachedAttendanceLogs();
    _saveAllToCache([record, ...cached.where((r) => r.id != record.id)]);
  }

  void _saveAllToCache(List<AttendanceModel> list) {
    try {
      final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
      _box?.put(_storageKey, encoded);
    } catch (_) {}
  }

  /// Client-side distance between two lat/lng coordinates in meters (Haversine formula)
  static double calculateDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742000 * asin(sqrt(a));
  }
}
