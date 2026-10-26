import "package:flutter_riverpod/flutter_riverpod.dart";

import "/models/attendance_model.dart";
import "/services/attendance_service.dart";

class AttendanceState {
  final List<AttendanceModel> records;
  final bool isLoading;
  final bool isSubmitting;
  final String? message;
  final String? errorMessage;
  final String currentLatitude;
  final String currentLongitude;
  final bool isWithinGeofence;
  final String? capturedPhotoPath;

  const AttendanceState({
    required this.records,
    this.isLoading = false,
    this.isSubmitting = false,
    this.message,
    this.errorMessage,
    this.currentLatitude = "28.6140",
    this.currentLongitude = "77.2092",
    this.isWithinGeofence = true,
    this.capturedPhotoPath,
  });

  factory AttendanceState.initial() =>
      const AttendanceState(records: [], isLoading: false, isSubmitting: false);

  bool get hasCheckedInToday {
    if (records.isEmpty) return false;
    final now = DateTime.now();
    return records.any(
      (r) =>
          r.timestamp.year == now.year &&
          r.timestamp.month == now.month &&
          r.timestamp.day == now.day,
    );
  }

  AttendanceModel? get latestRecord => records.firstOrNull;

  AttendanceState copyWith({
    List<AttendanceModel>? records,
    bool? isLoading,
    bool? isSubmitting,
    String? message,
    String? errorMessage,
    String? currentLatitude,
    String? currentLongitude,
    bool? isWithinGeofence,
    String? capturedPhotoPath,
    bool clearPhoto = false,
  }) {
    return AttendanceState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      message: message,
      errorMessage: errorMessage,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      isWithinGeofence: isWithinGeofence ?? this.isWithinGeofence,
      capturedPhotoPath: clearPhoto
          ? null
          : (capturedPhotoPath ?? this.capturedPhotoPath),
    );
  }
}

class AttendanceNotifier extends Notifier<AttendanceState> {
  @override
  AttendanceState build() {
    Future.microtask(() => loadRecords());
    return AttendanceState.initial();
  }

  AttendanceService get _service => ref.read(attendanceServiceProvider);

  Future<void> loadRecords({String? storeName}) async {
    final cached = _service.getCachedAttendanceLogs();
    if (cached.isNotEmpty) state = state.copyWith(records: cached);

    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await _service.fetchAllAttendance(fallbackStoreName: storeName);
    state = state.copyWith(
      records: res.data ?? state.records,
      isLoading: false,
    );
  }

  void setCapturedPhoto(String? path) {
    state = state.copyWith(
      capturedPhotoPath: path,
      clearPhoto: path == null,
      errorMessage: null,
    );
  }

  void clearCapturedPhoto() {
    state = state.copyWith(clearPhoto: true, errorMessage: null);
  }

  /// Clock in with live selfie and GPS geofence verification
  Future<bool> checkIn({
    required String userId,
    String? userName,
    String? storeName,
    String? photoPath,
  }) async {
    final photo = photoPath ?? state.capturedPhotoPath;
    if (photo == null || photo.isEmpty) {
      state = state.copyWith(errorMessage: "Live selfie required to punch in");
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      message: null,
      errorMessage: null,
    );

    // 1. Request presigned S3 upload URL
    final presigned = await _service.requestUploadUrl(text: "User: $userId");
    String imageKey = "images/${DateTime.now().millisecondsSinceEpoch}.webp";

    if (presigned.isSuccess && presigned.data != null) {
      imageKey = presigned.data!["imageKey"]!;
      final ok = await _service.uploadSelfieToS3(
        uploadUrl: presigned.data!["uploadUrl"]!,
        localFilePath: photo,
      );
      if (!ok) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: "Failed to upload selfie proof to cloud storage.",
        );
        return false;
      }
    }

    // 2. Submit attendance to backend (distance computed automatically by backend)
    final res = await _service.submitAttendance(
      latitude: state.currentLatitude,
      longitude: state.currentLongitude,
      imageUrl: imageKey,
      storeName: storeName,
      userName: userName,
    );

    if (res.isSuccess && res.data != null) {
      final record = res.data!;
      final updated = [
        record,
        ...state.records.where((r) => r.id != record.id),
      ];
      final distMsg = record.distance != null
          ? " (${record.distance}m from branch)"
          : "";

      state = state.copyWith(
        records: updated,
        isSubmitting: false,
        isWithinGeofence: record.isVerified,
        clearPhoto: true,
        message: "Attendance recorded successfully!$distMsg",
      );
      return true;
    }

    state = state.copyWith(
      isSubmitting: false,
      errorMessage: res.message ?? "Failed to log attendance.",
    );
    return false;
  }
}

final attendanceServiceProvider = Provider<AttendanceService>(
  (ref) => AttendanceService(),
);

final attendanceProvider =
    NotifierProvider<AttendanceNotifier, AttendanceState>(
      AttendanceNotifier.new,
    );
