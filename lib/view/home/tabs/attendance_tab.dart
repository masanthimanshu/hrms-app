import "dart:async";
import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:image_picker/image_picker.dart";

import "/models/store_model.dart";
import "/providers/attendance_provider.dart";
import "/providers/auth_provider.dart";
import "/providers/store_provider.dart";
import "/services/attendance_service.dart";
import "/utils/colors.dart";
import "/utils/formatters.dart";
import "/widgets/monochrome_button.dart";
import "/widgets/monochrome_card.dart";
import "/widgets/status_pill.dart";

class AttendanceTab extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToHistory;

  const AttendanceTab({super.key, this.onNavigateToHistory});

  @override
  ConsumerState<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<AttendanceTab> {
  final ImagePicker _picker = ImagePicker();
  String? _localPhotoPath;
  late DateTime _currentTime;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo != null && mounted) {
        setState(() => _localPhotoPath = photo.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Camera error: $e")));
      }
    }
  }

  void _clearPhoto() => setState(() => _localPhotoPath = null);

  void _punchAttendance(
    StoreModel? store,
    String? userId,
    String? userName,
  ) async {
    if (_localPhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Live selfie photo required. Please tap 'Open Camera'.",
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final attState = ref.read(attendanceProvider);
    if (attState.currentLatitude == null || attState.currentLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Live GPS coordinates required. Please wait for GPS to resolve.",
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "User session not identified. Please wait for profile to load.",
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final success = await ref
        .read(attendanceProvider.notifier)
        .checkIn(
          userId: userId,
          userName: userName,
          storeName: store?.name,
          photoPath: _localPhotoPath!,
        );

    if (!mounted) return;

    if (success) {
      setState(() => _localPhotoPath = null);
      final msg =
          ref.read(attendanceProvider).message ?? "Attendance recorded!";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.zinc950,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final err =
          ref.read(attendanceProvider).errorMessage ??
          "Failed to log attendance.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.statusErrorDot,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _reticleCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          border: Border(
            top: top != null
                ? const BorderSide(color: AppColors.white, width: 2)
                : BorderSide.none,
            bottom: bottom != null
                ? const BorderSide(color: AppColors.white, width: 2)
                : BorderSide.none,
            left: left != null
                ? const BorderSide(color: AppColors.white, width: 2)
                : BorderSide.none,
            right: right != null
                ? const BorderSide(color: AppColors.white, width: 2)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final storeState = ref.watch(storeProvider);
    final attendanceState = ref.watch(attendanceProvider);

    final currentUser = authState.currentUser;
    final hasUser = currentUser != null && currentUser.name.isNotEmpty;
    final userName = hasUser
        ? currentUser.name
        : (authState.isLoading ? "Loading..." : "Employee");

    StoreModel? assignedStore;
    if (storeState.stores.isNotEmpty) {
      final matches = storeState.stores.where(
        (s) => s.id == currentUser?.storeId,
      );
      assignedStore = matches.isNotEmpty
          ? matches.first
          : storeState.stores.first;
    }

    final hasCheckedIn = attendanceState.hasCheckedInToday;

    // Clock format
    final h = _currentTime.hour;
    final displayHour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final period = h >= 12 ? "PM" : "AM";
    final timeStr =
        "${displayHour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}:${_currentTime.second.toString().padLeft(2, '0')} $period";

    final hasGps =
        attendanceState.currentLatitude != null &&
        attendanceState.currentLongitude != null;

    double? liveDistance;
    if (hasGps && assignedStore != null) {
      final sLat = double.tryParse(assignedStore.latitude);
      final sLng = double.tryParse(assignedStore.longitude);
      final cLat = double.tryParse(attendanceState.currentLatitude!);
      final cLng = double.tryParse(attendanceState.currentLongitude!);
      if (sLat != null && sLng != null && cLat != null && cLng != null) {
        liveDistance = AttendanceService.calculateDistanceMeters(
          cLat,
          cLng,
          sLat,
          sLng,
        );
      }
    }

    final inRange = liveDistance != null && liveDistance <= 1000;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live Clock Card
          MonochromeCard(
            backgroundColor: AppColors.zinc950,
            borderColor: AppColors.zinc800,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.statusActiveDot,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "TERMINAL ONLINE",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppColors.zinc400,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      AppFormatters.formatShortDate(_currentTime),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.zinc300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontFamily: "monospace",
                    letterSpacing: -1.0,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: AppColors.zinc400,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        "Signed in: $userName",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.zinc300,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Geofence & Location Bar
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              ref
                  .read(attendanceProvider.notifier)
                  .startLocationStream(forceCurrent: true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Refreshing live GPS coordinates..."),
                  duration: Duration(milliseconds: 1000),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.zinc200, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    attendanceState.isRealTimeGps
                        ? Icons.gps_fixed
                        : Icons.location_searching,
                    size: 16,
                    color: attendanceState.isRealTimeGps
                        ? AppColors.zinc950
                        : AppColors.zinc500,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                assignedStore?.name ??
                                    (storeState.isLoading
                                        ? "Loading facility..."
                                        : "Workplace Facility"),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.zinc950,
                                ),
                              ),
                            ),
                            if (attendanceState.isRealTimeGps) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.zinc100,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: AppColors.zinc300,
                                    width: 0.5,
                                  ),
                                ),
                                child: const Text(
                                  "LIVE",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.zinc900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          hasGps
                              ? (liveDistance != null
                                    ? "GPS: ${attendanceState.currentLatitude}, ${attendanceState.currentLongitude} • ${liveDistance.round()}m from facility"
                                    : "GPS: ${attendanceState.currentLatitude}, ${attendanceState.currentLongitude}")
                              : "Locating live GPS coordinates...",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: "monospace",
                            color: AppColors.zinc500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusPill(
                    label: liveDistance != null
                        ? (inRange
                              ? "In Range (${liveDistance.round()}m)"
                              : "Far (${liveDistance.round()}m)")
                        : (hasGps ? "Live GPS" : "Locating"),
                    type: liveDistance != null
                        ? (inRange
                              ? StatusPillType.active
                              : StatusPillType.warning)
                        : (hasGps
                              ? StatusPillType.neutral
                              : StatusPillType.warning),
                    showDot: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Camera Viewfinder Section
          MonochromeCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Facial Photo Proof",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zinc950,
                        letterSpacing: -0.2,
                      ),
                    ),
                    StatusPill(
                      label: _localPhotoPath != null
                          ? "Photo Ready"
                          : "Camera Only",
                      type: _localPhotoPath != null
                          ? StatusPillType.active
                          : StatusPillType.neutral,
                      showDot: _localPhotoPath != null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Viewfinder Box
                Container(
                  height: 230,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.zinc800, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_localPhotoPath != null)
                          kIsWeb
                              ? Image.network(
                                  _localPhotoPath!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_localPhotoPath!),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                )
                        else
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 92,
                                height: 110,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.zinc700,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(46),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_outline,
                                    size: 42,
                                    color: AppColors.zinc600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Live Camera Shutter",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.zinc300,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Tap button below to capture attendance selfie",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.zinc500,
                                ),
                              ),
                            ],
                          ),

                        // Corner Reticles
                        _reticleCorner(top: 14, left: 14),
                        _reticleCorner(top: 14, right: 14),
                        _reticleCorner(bottom: 14, left: 14),
                        _reticleCorner(bottom: 14, right: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Camera Action
                Row(
                  children: [
                    Expanded(
                      child: MonochromeButton(
                        text: _localPhotoPath == null
                            ? "Open Camera & Take Selfie"
                            : "Retake Live Selfie",
                        icon: Icons.camera_alt,
                        onPressed: _capturePhoto,
                        height: 46,
                      ),
                    ),
                    if (_localPhotoPath != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppColors.zinc700,
                        ),
                        tooltip: "Clear Photo",
                        onPressed: _clearPhoto,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 12,
                      color: AppColors.zinc500,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Live camera required",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.zinc500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Submit Button
          MonochromeButton(
            text: _localPhotoPath == null
                ? "Capture Photo Above to Punch In"
                : "Submit Attendance Record",
            icon: Icons.check_circle_outline,
            isLoading: attendanceState.isSubmitting,
            height: 50,
            onPressed: () =>
                _punchAttendance(assignedStore, currentUser?.id, userName),
          ),
          const SizedBox(height: 20),

          // Today's Status Banner
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              ref
                  .read(attendanceProvider.notifier)
                  .setFilter(AttendanceFilter.today);
              widget.onNavigateToHistory?.call();
            },
            child: MonochromeCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: hasCheckedIn
                          ? AppColors.zinc950
                          : AppColors.zinc100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      hasCheckedIn ? Icons.check : Icons.access_time,
                      size: 20,
                      color: hasCheckedIn ? AppColors.white : AppColors.zinc600,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasCheckedIn
                              ? "Attendance Verified"
                              : "Attendance Pending",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.zinc950,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasCheckedIn
                              ? "${attendanceState.todayRecords.length} check-in${attendanceState.todayRecords.length == 1 ? '' : 's'} logged today • Tap to view"
                              : "Take a selfie and punch in to register your day.",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.zinc500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusPill(
                    label: hasCheckedIn
                        ? "${attendanceState.todayRecords.length} Logged"
                        : "Pending",
                    type: hasCheckedIn
                        ? StatusPillType.active
                        : StatusPillType.warning,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
