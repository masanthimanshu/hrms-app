import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:geolocator/geolocator.dart";

import "/models/attendance_model.dart";
import "/services/attendance_service.dart";
import "auth_provider.dart";
import "store_provider.dart";

enum AttendanceFilter { today, all }

class AttendanceState {
  final List<AttendanceModel> allRecords;
  final List<AttendanceModel> todayRecords;
  final AttendanceFilter selectedFilter;
  final bool isLoading;
  final bool isSubmitting;
  final String? message;
  final String? errorMessage;
  final String? currentLatitude;
  final String? currentLongitude;
  final bool isRealTimeGps;

  const AttendanceState({
    this.allRecords = const [],
    this.todayRecords = const [],
    this.selectedFilter = AttendanceFilter.today,
    this.isLoading = false,
    this.isSubmitting = false,
    this.message,
    this.errorMessage,
    this.currentLatitude,
    this.currentLongitude,
    this.isRealTimeGps = false,
  });

  List<AttendanceModel> get records =>
      selectedFilter == AttendanceFilter.today ? todayRecords : allRecords;

  bool get hasCheckedInToday {
    if (todayRecords.isNotEmpty) return true;
    final now = DateTime.now();
    return allRecords.any(
      (r) =>
          r.timestamp.year == now.year &&
          r.timestamp.month == now.month &&
          r.timestamp.day == now.day,
    );
  }

  AttendanceState copyWith({
    List<AttendanceModel>? allRecords,
    List<AttendanceModel>? todayRecords,
    AttendanceFilter? selectedFilter,
    bool? isLoading,
    bool? isSubmitting,
    String? message,
    String? errorMessage,
    String? currentLatitude,
    String? currentLongitude,
    bool? isRealTimeGps,
  }) {
    return AttendanceState(
      allRecords: allRecords ?? this.allRecords,
      todayRecords: todayRecords ?? this.todayRecords,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      message: message,
      errorMessage: errorMessage,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      isRealTimeGps: isRealTimeGps ?? this.isRealTimeGps,
    );
  }
}

class AttendanceNotifier extends Notifier<AttendanceState> {
  StreamSubscription<Position>? _positionSubscription;

  @override
  AttendanceState build() {
    ref.onDispose(() {
      _positionSubscription?.cancel();
    });
    Future.microtask(() {
      loadRecords();
      startLocationStream();
    });
    return const AttendanceState();
  }

  AttendanceService get _service => ref.read(attendanceServiceProvider);

  String? _resolveStoreName() {
    try {
      final userStoreId = ref.read(authProvider).currentUser?.storeId;
      final stores = ref.read(storeProvider).stores;
      final match = stores.where((s) => s.id == userStoreId);
      if (match.isNotEmpty) return match.first.name;
      if (stores.isNotEmpty) return stores.first.name;
    } catch (_) {}
    return null;
  }

  Future<void> startLocationStream({bool forceCurrent = false}) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && !forceCurrent) {
        state = state.copyWith(
          currentLatitude: lastKnown.latitude.toStringAsFixed(6),
          currentLongitude: lastKnown.longitude.toStringAsFixed(6),
          isRealTimeGps: true,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      state = state.copyWith(
        currentLatitude: position.latitude.toStringAsFixed(6),
        currentLongitude: position.longitude.toStringAsFixed(6),
        isRealTimeGps: true,
      );

      await _positionSubscription?.cancel();
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 1,
            ),
          ).listen((Position pos) {
            state = state.copyWith(
              currentLatitude: pos.latitude.toStringAsFixed(6),
              currentLongitude: pos.longitude.toStringAsFixed(6),
              isRealTimeGps: true,
            );
          }, onError: (_) {});
    } catch (_) {}
  }

  void setFilter(AttendanceFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  Future<void> loadRecords({String? storeName}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final targetStore = storeName ?? _resolveStoreName();

    final results = await Future.wait([
      _service.fetchTodayAttendance(fallbackStoreName: targetStore),
      _service.fetchAllAttendance(fallbackStoreName: targetStore),
    ]);

    state = state.copyWith(
      todayRecords: results[0].data ?? state.todayRecords,
      allRecords: results[1].data ?? state.allRecords,
      isLoading: false,
    );
  }

  Future<void> fetchToday({String? storeName}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final targetStore = storeName ?? _resolveStoreName();
    final res = await _service.fetchTodayAttendance(
      fallbackStoreName: targetStore,
    );
    state = state.copyWith(
      todayRecords: res.data ?? state.todayRecords,
      isLoading: false,
    );
  }

  Future<void> fetchAll({String? storeName}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final targetStore = storeName ?? _resolveStoreName();
    final res = await _service.fetchAllAttendance(
      fallbackStoreName: targetStore,
    );
    state = state.copyWith(
      allRecords: res.data ?? state.allRecords,
      isLoading: false,
    );
  }

  Future<bool> checkIn({
    required String userId,
    String? userName,
    String? storeName,
    required String photoPath,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      message: null,
      errorMessage: null,
    );

    // Ensure absolute fresh real-time GPS coordinates right before check-in
    try {
      final livePos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      );
      state = state.copyWith(
        currentLatitude: livePos.latitude.toStringAsFixed(6),
        currentLongitude: livePos.longitude.toStringAsFixed(6),
        isRealTimeGps: true,
      );
    } catch (_) {}

    if (state.currentLatitude == null || state.currentLongitude == null) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: "Real-time GPS location not detected. Please enable GPS.",
      );
      return false;
    }

    // 1. Get presigned upload URL
    final presigned = await _service.requestUploadUrl(text: "User: $userId");
    if (!presigned.isSuccess || presigned.data == null) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: presigned.message ?? "Failed to obtain upload URL",
      );
      return false;
    }

    // 2. Upload photo to S3
    final ok = await _service.uploadSelfieToS3(
      uploadUrl: presigned.data!["uploadUrl"]!,
      localFilePath: photoPath,
    );
    if (!ok) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: "Failed to upload selfie to cloud storage",
      );
      return false;
    }

    // 3. Submit attendance record
    final effectiveStoreName = storeName ?? _resolveStoreName();
    final res = await _service.submitAttendance(
      latitude: state.currentLatitude!,
      longitude: state.currentLongitude!,
      imageUrl: presigned.data!["imageKey"]!,
      storeName: effectiveStoreName,
    );

    if (res.isSuccess && res.data != null) {
      final record = res.data!;
      final distMsg = record.distance != null
          ? " (${record.distance}m from branch)"
          : "";
      state = state.copyWith(
        todayRecords: [
          record,
          ...state.todayRecords.where((r) => r.id != record.id),
        ],
        allRecords: [
          record,
          ...state.allRecords.where((r) => r.id != record.id),
        ],
        isSubmitting: false,
        message: "Attendance recorded successfully!$distMsg",
      );
      loadRecords(storeName: effectiveStoreName);
      return true;
    }

    state = state.copyWith(
      isSubmitting: false,
      errorMessage: res.message ?? "Failed to log attendance",
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
