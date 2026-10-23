import "package:flutter_riverpod/flutter_riverpod.dart";

import "/models/attendance_model.dart";
import "/services/attendance_service.dart";

class AttendanceState {
  final List<AttendanceModel> records;
  final bool isSubmitting;
  final String? message;
  final String currentLatitude;
  final String currentLongitude;
  final bool isWithinGeofence;
  final String? capturedPhotoPath;

  const AttendanceState({
    required this.records,
    this.isSubmitting = false,
    this.message,
    this.currentLatitude = "37.7892",
    this.currentLongitude = "-122.3982",
    this.isWithinGeofence = true,
    this.capturedPhotoPath,
  });

  factory AttendanceState.initial() {
    return const AttendanceState(records: [], isSubmitting: false);
  }

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

  AttendanceModel? get latestRecord =>
      records.isNotEmpty ? records.first : null;

  AttendanceState copyWith({
    List<AttendanceModel>? records,
    bool? isSubmitting,
    String? message,
    String? currentLatitude,
    String? currentLongitude,
    bool? isWithinGeofence,
    String? capturedPhotoPath,
    bool clearPhoto = false,
  }) {
    return AttendanceState(
      records: records ?? this.records,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      message: message,
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

  void loadRecords() {
    final list = _service.getAttendanceLogs();
    state = state.copyWith(records: list);
  }

  void setCapturedPhoto(String? path) {
    state = state.copyWith(capturedPhotoPath: path, clearPhoto: path == null);
  }

  void clearCapturedPhoto() {
    state = state.copyWith(clearPhoto: true);
  }

  Future<bool> checkIn({
    required String userId,
    String? userName,
    String? storeId,
    String? storeName,
    String? targetLat,
    String? targetLng,
    String? photoPath,
  }) async {
    state = state.copyWith(isSubmitting: true, message: null);

    // Verify distance to store geofence
    bool verified = true;
    if (targetLat != null && targetLng != null) {
      final double? tLat = double.tryParse(targetLat);
      final double? tLng = double.tryParse(targetLng);
      final double? cLat = double.tryParse(state.currentLatitude);
      final double? cLng = double.tryParse(state.currentLongitude);

      if (tLat != null && tLng != null && cLat != null && cLng != null) {
        final distMeters = AttendanceService.calculateDistanceMeters(
          cLat,
          cLng,
          tLat,
          tLng,
        );
        verified = distMeters <= 1000;
      }
    }

    // Persist check-in record
    final record = await _service.recordAttendance(
      userId: userId,
      userName: userName,
      storeId: storeId,
      storeName: storeName,
      latitude: state.currentLatitude,
      longitude: state.currentLongitude,
      imageUrl: photoPath ?? state.capturedPhotoPath,
      isVerified: verified,
    );

    final updated = [record, ...state.records.where((r) => r.id != record.id)];

    state = state.copyWith(
      records: updated,
      isSubmitting: false,
      isWithinGeofence: verified,
      clearPhoto: true,
      message: verified
          ? "Attendance verified & logged successfully with selfie proof!"
          : "Attendance logged (warning: outside branch geofence)",
    );

    return true;
  }
}

final attendanceServiceProvider = Provider<AttendanceService>(
  (ref) => AttendanceService(),
);

final attendanceProvider =
    NotifierProvider<AttendanceNotifier, AttendanceState>(
      AttendanceNotifier.new,
    );
