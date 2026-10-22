import "dart:io";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:image_picker/image_picker.dart";

import "/models/store_model.dart";
import "/providers/attendance_provider.dart";
import "/providers/auth_provider.dart";
import "/providers/store_provider.dart";
import "/utils/colors.dart";
import "/utils/formatters.dart";
import "/widgets/monochrome_button.dart";
import "/widgets/monochrome_card.dart";
import "/widgets/section_header.dart";
import "/widgets/status_pill.dart";

class AttendanceTab extends ConsumerStatefulWidget {
  const AttendanceTab({super.key});

  @override
  ConsumerState<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<AttendanceTab> {
  final ImagePicker _picker = ImagePicker();
  String? _localPhotoPath;

  Future<void> _capturePhoto(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Camera/Photo access: $e")),
        );
      }
    }
  }

  void _clearPhoto() {
    setState(() {
      _localPhotoPath = null;
    });
    ref.read(attendanceProvider.notifier).clearCapturedPhoto();
  }

  void _punchAttendance(StoreModel? assignedStore, String? userId, String? userName) async {
    if (_localPhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please take a selfie photo of yourself first to verify attendance."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final success = await ref.read(attendanceProvider.notifier).checkIn(
          userId: userId ?? "emp-user",
          userName: userName,
          storeId: assignedStore?.id,
          storeName: assignedStore?.name,
          targetLat: assignedStore?.latitude,
          targetLng: assignedStore?.longitude,
          photoPath: _localPhotoPath,
        );

    if (success && mounted) {
      setState(() {
        _localPhotoPath = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attendance successfully verified and logged!"),
          backgroundColor: AppColors.zinc950,
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Greeting & Store Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppFormatters.formatShortDate(DateTime.now()).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zinc500,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Hello, $userName",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.zinc950,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: hasCheckedIn ? "Logged In" : "Pending",
                type: hasCheckedIn ? StatusPillType.active : StatusPillType.warning,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Assigned Store Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.zinc100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.zinc200, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.storefront_outlined, size: 16, color: AppColors.zinc700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    assignedStore != null
                        ? "Assigned Facility: ${assignedStore.name}"
                        : "No facility linked",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.zinc800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Selfie Capture & Photo Proof Card
          MonochromeCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.face_outlined, size: 18, color: AppColors.zinc900),
                        SizedBox(width: 8),
                        Text(
                          "Selfie Photo Proof",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.zinc950,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    if (_localPhotoPath != null)
                      const StatusPill(
                        label: "Photo Ready",
                        type: StatusPillType.active,
                        showDot: true,
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Viewfinder / Photo Container
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.zinc950,
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
                              // Face silhouette guide
                              Container(
                                width: 84,
                                height: 104,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.zinc700,
                                    width: 1.5,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(42),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    size: 32,
                                    color: AppColors.zinc500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                "Position your face inside the frame",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.zinc400,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Required for attendance verification",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.zinc600,
                                ),
                              ),
                            ],
                          ),

                        // Corner Viewfinder Brackets
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: AppColors.white, width: 2),
                                left: BorderSide(color: AppColors.white, width: 2),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: AppColors.white, width: 2),
                                right: BorderSide(color: AppColors.white, width: 2),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.white, width: 2),
                                left: BorderSide(color: AppColors.white, width: 2),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.white, width: 2),
                                right: BorderSide(color: AppColors.white, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Camera Action Buttons
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: MonochromeButton(
                        text: _localPhotoPath == null ? "Take Selfie" : "Retake Photo",
                        icon: Icons.camera,
                        onPressed: () => _capturePhoto(ImageSource.camera),
                        height: 42,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: MonochromeButton(
                        text: "Gallery",
                        icon: Icons.photo_library_outlined,
                        variant: MonochromeButtonVariant.secondary,
                        onPressed: () => _capturePhoto(ImageSource.gallery),
                        height: 42,
                      ),
                    ),
                    if (_localPhotoPath != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.zinc700),
                        tooltip: "Remove Photo",
                        onPressed: _clearPhoto,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Location & Geofence Coordinates Card
          MonochromeCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: AppColors.zinc50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: AppColors.zinc800),
                        SizedBox(width: 6),
                        Text(
                          "GPS Location & Geofence",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.zinc950,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.zinc200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "Verified",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.zinc800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Current Coordinates",
                      style: TextStyle(fontSize: 12, color: AppColors.zinc600),
                    ),
                    Text(
                      "${attendanceState.currentLatitude}, ${attendanceState.currentLongitude}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: "monospace",
                        fontWeight: FontWeight.w600,
                        color: AppColors.zinc950,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Target Branch",
                      style: TextStyle(fontSize: 12, color: AppColors.zinc600),
                    ),
                    Flexible(
                      child: Text(
                        assignedStore?.name ?? "HQ Facility",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.zinc950,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Main Submit Button
          MonochromeButton(
            text: _localPhotoPath == null
                ? "Take Photo Above to Clock In"
                : "Submit Attendance & Log In",
            icon: Icons.check_circle_outline,
            isLoading: attendanceState.isSubmitting,
            height: 50,
            onPressed: () => _punchAttendance(assignedStore, currentUser?.id, userName),
          ),
          const SizedBox(height: 24),

          // Recent Personal Log
          const SectionHeader(
            title: "Today's Status",
            subtitle: "Personal attendance log record for today",
          ),
          const SizedBox(height: 10),

          MonochromeCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
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
                            ? "Attendance Logged Today"
                            : "Attendance Not Logged Yet",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.zinc950,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasCheckedIn
                            ? "Logged at ${AppFormatters.formatDate(attendanceState.latestRecord?.timestamp)}"
                            : "Capture your photo above to submit attendance.",
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
                  label: hasCheckedIn ? "Active" : "Pending",
                  type: hasCheckedIn ? StatusPillType.active : StatusPillType.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
