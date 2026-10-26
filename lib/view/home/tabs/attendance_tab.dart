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
  const AttendanceTab({super.key});

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
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _localPhotoPath = photo.path;
        });
        ref.read(attendanceProvider.notifier).setCapturedPhoto(photo.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Camera access error: $e")));
      }
    }
  }

  void _clearPhoto() {
    setState(() {
      _localPhotoPath = null;
    });
    ref.read(attendanceProvider.notifier).clearCapturedPhoto();
  }

  void _punchAttendance(
    StoreModel? assignedStore,
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

    final success = await ref
        .read(attendanceProvider.notifier)
        .checkIn(
          userId: userId ?? "emp-user",
          userName: userName,
          storeName: assignedStore?.name,
          photoPath: _localPhotoPath,
        );

    if (!mounted) return;

    if (success) {
      setState(() {
        _localPhotoPath = null;
      });
      final msg =
          ref.read(attendanceProvider).message ??
          "Attendance successfully verified and recorded!";
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
          "Failed to record attendance. Please try again.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.statusErrorDot,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final storeState = ref.watch(storeProvider);
    final attendanceState = ref.watch(attendanceProvider);

    final currentUser = authState.currentUser;
    final userName = currentUser?.name ?? "Employee";

    StoreModel? assignedStore;
    if (storeState.stores.isNotEmpty) {
      assignedStore = storeState.stores.firstWhere(
        (s) => s.id == currentUser?.storeId,
        orElse: () => storeState.stores.first,
      );
    }

    final hasCheckedIn = attendanceState.hasCheckedInToday;

    // Format clock
    final hour = _currentTime.hour;
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = hour >= 12 ? "PM" : "AM";
    final timeStr =
        "${displayHour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}:${_currentTime.second.toString().padLeft(2, '0')} $period";

    double? liveDistanceMeters;
    if (assignedStore?.latitude != null && assignedStore?.longitude != null) {
      final sLat = double.tryParse(assignedStore!.latitude);
      final sLng = double.tryParse(assignedStore.longitude);
      final cLat = double.tryParse(attendanceState.currentLatitude);
      final cLng = double.tryParse(attendanceState.currentLongitude);
      if (sLat != null && sLng != null && cLat != null && cLng != null) {
        liveDistanceMeters = AttendanceService.calculateDistanceMeters(
          cLat,
          cLng,
          sLat,
          sLng,
        );
      }
    }

    final isWithinRange =
        liveDistanceMeters == null || liveDistanceMeters <= 1000;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live Clock & Date Terminal Card
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.zinc200, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.gps_fixed, size: 16, color: AppColors.zinc800),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignedStore?.name ?? "Headquarters - San Francisco",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.zinc950,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        liveDistanceMeters != null
                            ? "GPS: ${attendanceState.currentLatitude}, ${attendanceState.currentLongitude} • ${liveDistanceMeters.round()}m from facility"
                            : "GPS: ${attendanceState.currentLatitude}, ${attendanceState.currentLongitude} • In Geofence",
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
                  label: liveDistanceMeters != null
                      ? (isWithinRange
                            ? "In Range (${liveDistanceMeters.round()}m)"
                            : "Far (${liveDistanceMeters.round()}m)")
                      : "In Range",
                  type: isWithinRange
                      ? StatusPillType.active
                      : StatusPillType.warning,
                  showDot: true,
                ),
              ],
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
                    if (_localPhotoPath != null)
                      const StatusPill(
                        label: "Photo Ready",
                        type: StatusPillType.active,
                        showDot: true,
                      )
                    else
                      const StatusPill(
                        label: "Camera Only",
                        type: StatusPillType.neutral,
                        showDot: false,
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Camera Viewfinder Box
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
                              // Viewfinder target ring
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

                        // Corner Viewfinder Reticles
                        Positioned(
                          top: 14,
                          left: 14,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                                left: BorderSide(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                                right: BorderSide(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 14,
                          left: 14,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                                left: BorderSide(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 14,
                          right: 14,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                                right: BorderSide(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Live Camera Shutter Button
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

          // Primary Punch In Action
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
          MonochromeCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: hasCheckedIn ? AppColors.zinc950 : AppColors.zinc100,
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
                            ? "Attendance Verified Today"
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
                            ? "Logged at ${AppFormatters.formatTime(attendanceState.latestRecord?.timestamp)}"
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
                  label: hasCheckedIn ? "Logged" : "Pending",
                  type: hasCheckedIn
                      ? StatusPillType.active
                      : StatusPillType.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
