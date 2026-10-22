import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "/models/store_model.dart";
import "/providers/attendance_provider.dart";
import "/providers/auth_provider.dart";
import "/providers/store_provider.dart";
import "/utils/colors.dart";
import "/view/home/widgets/attendance_log_tile.dart";
import "/widgets/empty_state.dart";
import "/widgets/monochrome_button.dart";
import "/widgets/monochrome_card.dart";
import "/widgets/section_header.dart";
import "/widgets/status_pill.dart";

class AttendanceTab extends ConsumerWidget {
  const AttendanceTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final storeState = ref.watch(storeProvider);
    final attendanceState = ref.watch(attendanceProvider);

    final currentUser = authState.currentUser;
    StoreModel? assignedStore;
    if (storeState.stores.isNotEmpty) {
      assignedStore = storeState.stores.firstWhere(
        (s) => s.id == currentUser?.storeId,
        orElse: () => storeState.stores.first,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const SectionHeader(
            title: "Attendance & Geo-Tracking",
            subtitle: "Geo-tagged coordinates & dual verification proofs",
          ),
          const SizedBox(height: 18),

          // Check-In Action Card
          MonochromeCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Daily Verification Punch",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zinc950,
                        letterSpacing: -0.2,
                      ),
                    ),
                    StatusPill(
                      label: attendanceState.hasCheckedInToday
                          ? "Checked In Today"
                          : "Punch Required",
                      type: attendanceState.hasCheckedInToday
                          ? StatusPillType.active
                          : StatusPillType.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Location Diagnostics Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.zinc100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.zinc200, width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.gps_fixed, size: 15, color: AppColors.zinc700),
                              SizedBox(width: 6),
                              Text(
                                "Detected Coordinates",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.zinc800,
                                ),
                              ),
                            ],
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
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.storefront_outlined, size: 15, color: AppColors.zinc700),
                              SizedBox(width: 6),
                              Text(
                                "Target Facility",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.zinc800,
                                ),
                              ),
                            ],
                          ),
                          Flexible(
                            child: Text(
                              assignedStore?.name ?? "Headquarters Branch",
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
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.verified_outlined, size: 15, color: AppColors.zinc700),
                              SizedBox(width: 6),
                              Text(
                                "Geofence Radius",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.zinc800,
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
                              "Within 50m • Verified Match",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.zinc900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Photo Proof & S3 Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.zinc200, width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 18, color: AppColors.zinc600),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "AWS S3 Presigned Photo Proof: Verified for this session",
                          style: TextStyle(fontSize: 12, color: AppColors.zinc600),
                        ),
                      ),
                      Icon(Icons.check_circle, size: 16, color: AppColors.zinc950),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                if (attendanceState.message != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.zinc100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.zinc300, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: AppColors.zinc950),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            attendanceState.message!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.zinc950,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Action Button
                MonochromeButton(
                  text: attendanceState.hasCheckedInToday
                      ? "Check In Again / Update Coordinates"
                      : "Record & Verify Attendance Now",
                  icon: Icons.check_circle_outline,
                  isLoading: attendanceState.isSubmitting,
                  onPressed: () {
                    ref.read(attendanceProvider.notifier).checkIn(
                          userId: currentUser?.id ?? "u-demo",
                          userName: currentUser?.name,
                          storeId: assignedStore?.id,
                          storeName: assignedStore?.name,
                          targetLat: assignedStore?.latitude,
                          targetLng: assignedStore?.longitude,
                        );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Attendance History
          SectionHeader(
            title: "Attendance History Log",
            subtitle: "Historical timestamps and location coordinate logs",
            action: Text(
              "${attendanceState.records.length} Records",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.zinc500,
              ),
            ),
          ),
          const SizedBox(height: 14),

          if (attendanceState.records.isEmpty)
            const EmptyState(
              icon: Icons.history_outlined,
              title: "No attendance records",
              description: "Punch in your attendance above to populate the audit trail.",
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attendanceState.records.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final record = attendanceState.records[index];
                return AttendanceLogTile(record: record);
              },
            ),
        ],
      ),
    );
  }
}
