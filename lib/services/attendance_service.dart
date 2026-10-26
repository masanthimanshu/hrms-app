import "dart:io";
import "dart:math";

import "package:flutter/foundation.dart";

import "/models/attendance_model.dart";
import "/network/api_response.dart";
import "/network/endpoints.dart";
import "/network/requests.dart";

class AttendanceService with HTTPRequests {
  Future<ApiResponse<Map<String, String>>> requestUploadUrl({
    String text = "Attendance selfie verification",
  }) async {
    final res = await postRequest(
      url: Endpoints.uploadImage,
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
    final errorMsg =
        res?["error"]?.toString() ??
        res?["message"]?.toString() ??
        "Failed to obtain upload URL";
    return ApiResponse.error(errorMsg);
  }

  Future<bool> uploadSelfieToS3({
    required String uploadUrl,
    required String localFilePath,
  }) async {
    try {
      final file = File(localFilePath);
      if (!await file.exists()) {
        debugPrint("[Upload S3] File not found: $localFilePath");
        return false;
      }
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        debugPrint("[Upload S3] File is empty: $localFilePath");
        return false;
      }
      return await uploadBinaryToUrl(url: uploadUrl, bytes: bytes);
    } catch (e) {
      debugPrint("[Upload S3] Error reading file: $e");
      return false;
    }
  }

  Future<ApiResponse<AttendanceModel>> submitAttendance({
    required String latitude,
    required String longitude,
    required String imageUrl,
    String? storeName,
  }) async {
    final res = await postRequest(
      url: Endpoints.attendanceAdd,
      payload: {
        "latitude": latitude,
        "longitude": longitude,
        "imageUrl": imageUrl,
      },
    );

    final rawData = res?["data"] ?? res?["attendance"] ?? res?["record"] ?? res;
    final dataMap = rawData is Map ? Map<String, dynamic>.from(rawData) : null;

    final hasRecordData =
        dataMap != null &&
        (dataMap["_id"] != null ||
            dataMap["id"] != null ||
            dataMap["userId"] != null ||
            dataMap["distance"] != null);

    final isSuccessStatus =
        res != null &&
        res["error"] == null &&
        (res["status"] == "Attendance added successfully" ||
            res["status"] == "Success" ||
            res["status"] == 200 ||
            res["message"] == "Attendance added successfully" ||
            res["message"] == "Success" ||
            hasRecordData);

    if (isSuccessStatus) {
      final record = hasRecordData
          ? AttendanceModel.fromJson(
              dataMap,
            ).copyWith(storeName: storeName ?? dataMap["storeName"]?.toString())
          : AttendanceModel(
              id: dataMap?["_id"]?.toString() ?? "",
              storeName: storeName,
              latitude: latitude,
              longitude: longitude,
              distance: dataMap?["distance"]?.toString(),
              imageUrl: imageUrl,
              timestamp: DateTime.now(),
              isVerified: true,
            );
      final msg =
          res["status"]?.toString() ??
          res["message"]?.toString() ??
          "Attendance recorded successfully";
      return ApiResponse.success(record, message: msg);
    }

    final errorMsg =
        res?["error"]?.toString() ??
        res?["message"]?.toString() ??
        res?["status"]?.toString() ??
        "Failed to record attendance";
    return ApiResponse.error(errorMsg);
  }

  Future<ApiResponse<List<AttendanceModel>>> _fetchList(
    String endpoint,
    String? fallbackStoreName,
  ) async {
    final res = await getRequest(endpoint);
    final rawList = res?["data"] ?? res?["attendance"];

    if (rawList is List) {
      final records = rawList.map((item) {
        final rec = AttendanceModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
        return (rec.storeName == null || rec.storeName!.isEmpty) &&
                fallbackStoreName != null
            ? rec.copyWith(storeName: fallbackStoreName)
            : rec;
      }).toList();

      records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return ApiResponse.success(records);
    }

    final errorMsg =
        res?["error"]?.toString() ??
        res?["message"]?.toString() ??
        "No records found";
    return ApiResponse.error(errorMsg);
  }

  Future<ApiResponse<List<AttendanceModel>>> fetchTodayAttendance({
    String? fallbackStoreName,
  }) => _fetchList(Endpoints.attendanceToday, fallbackStoreName);

  Future<ApiResponse<List<AttendanceModel>>> fetchAllAttendance({
    String? fallbackStoreName,
  }) => _fetchList(Endpoints.attendanceAll, fallbackStoreName);

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
