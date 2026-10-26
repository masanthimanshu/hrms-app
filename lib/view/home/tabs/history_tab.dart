import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "/providers/attendance_provider.dart";
import "/providers/auth_provider.dart";
import "/providers/store_provider.dart";
import "/utils/colors.dart";
import "/utils/formatters.dart";
import "/view/home/widgets/attendance_log_tile.dart";
import "/widgets/empty_state.dart";
import "/widgets/section_header.dart";
import "/widgets/stat_card.dart";
import "/widgets/status_pill.dart";

class HistoryTab extends ConsumerWidget {
  final VoidCallback onNavigateToPunch;

  const HistoryTab({super.key, required this.onNavigateToPunch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceProvider);
    final authState = ref.watch(authProvider);
    final storeState = ref.watch(storeProvider);

    final userStoreId = authState.currentUser?.storeId;
    final storeMatches = storeState.stores.where((s) => s.id == userStoreId);
    final assignedStore = storeMatches.isNotEmpty
        ? storeMatches.first
        : (storeState.stores.isNotEmpty ? storeState.stores.first : null);
    final fallbackStoreName = assignedStore?.name;

    final isToday = attendanceState.selectedFilter == AttendanceFilter.today;
    final todayRecords = attendanceState.todayRecords;
    final allRecords = attendanceState.allRecords;
    final records = attendanceState.records;

    final latestPunch = todayRecords.isNotEmpty
        ? todayRecords.reduce(
            (curr, next) =>
                curr.timestamp.isAfter(next.timestamp) ? curr : next,
          )
        : null;

    final verifiedCount = records.where((r) => r.isVerified).length;
    final verificationRate = records.isEmpty
        ? "100%"
        : "${((verifiedCount / records.length) * 100).round()}%";

    return RefreshIndicator(
      color: AppColors.zinc950,
      backgroundColor: AppColors.white,
      onRefresh: () async {
        await Future.wait([
          ref
              .read(attendanceProvider.notifier)
              .loadRecords(storeName: fallbackStoreName),
          ref.read(storeProvider.notifier).loadStores(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(
              title: "Attendance Logs",
              subtitle: "Today's check-ins & complete timesheet audit",
            ),
            const SizedBox(height: 12),

            // Segmented Control
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.zinc100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.zinc200, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _FilterSegmentButton(
                      label: "Today",
                      count: todayRecords.length,
                      icon: Icons.today_outlined,
                      isSelected: isToday,
                      onTap: () {
                        ref
                            .read(attendanceProvider.notifier)
                            .setFilter(AttendanceFilter.today);
                        ref.read(attendanceProvider.notifier).fetchToday();
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _FilterSegmentButton(
                      label: "All Records",
                      count: allRecords.length,
                      icon: Icons.calendar_month_outlined,
                      isSelected: !isToday,
                      onTap: () {
                        ref
                            .read(attendanceProvider.notifier)
                            .setFilter(AttendanceFilter.all);
                        ref.read(attendanceProvider.notifier).fetchAll();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // KPI Summary Cards
            Row(
              children: isToday
                  ? [
                      Expanded(
                        child: StatCard(
                          title: "Today's Punches",
                          value: "${todayRecords.length}",
                          subtitle: todayRecords.isEmpty
                              ? "No check-in yet"
                              : "${todayRecords.length} punched today",
                          icon: Icons.fingerprint,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: "Latest Punch",
                          value: latestPunch == null
                              ? "--:--"
                              : AppFormatters.formatTime(latestPunch.timestamp),
                          subtitle: latestPunch == null
                              ? "Awaiting check-in"
                              : (latestPunch.distance != null
                                    ? "${latestPunch.distance}m from facility"
                                    : (latestPunch.isVerified
                                          ? "Within 1000m range"
                                          : "Out of range")),
                          icon: Icons.access_time,
                        ),
                      ),
                    ]
                  : [
                      Expanded(
                        child: StatCard(
                          title: "Days Logged",
                          value: "${allRecords.length}",
                          subtitle: "Recorded check-ins",
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: "Verification",
                          value: verificationRate,
                          subtitle:
                              "$verifiedCount of ${allRecords.length} in range",
                          icon: Icons.verified_outlined,
                        ),
                      ),
                    ],
            ),
            const SizedBox(height: 16),

            // Section Header for Logs
            SectionHeader(
              title: isToday ? "Today's Punches" : "Check-In Logs",
              subtitle: isToday
                  ? "Real-time records from today's session"
                  : "Complete attendance timesheet audit",
              action: isToday
                  ? StatusPill(
                      label: "${todayRecords.length} Today",
                      type: todayRecords.isNotEmpty
                          ? StatusPillType.active
                          : StatusPillType.neutral,
                      showDot: todayRecords.isNotEmpty,
                    )
                  : Text(
                      "${records.length} Logs",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.zinc500,
                      ),
                    ),
            ),
            const SizedBox(height: 10),

            if (attendanceState.isLoading && records.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.zinc950,
                    ),
                  ),
                ),
              )
            else if (records.isEmpty)
              EmptyState(
                icon: isToday
                    ? Icons.today_outlined
                    : Icons.access_time_outlined,
                title: isToday
                    ? "No check-ins recorded today"
                    : "No attendance logs yet",
                description: isToday
                    ? "You haven't punched in yet today. Clock in with your camera to create today's first record."
                    : "Clock in using your camera to create your first attendance record.",
                buttonText: "Go to Punch In",
                onButtonPressed: onNavigateToPunch,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: records.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) => AttendanceLogTile(
                  record: records[index],
                  fallbackStoreName: fallbackStoreName,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterSegmentButton extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterSegmentButton({
    required this.label,
    required this.count,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.zinc950 : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.white : AppColors.zinc500,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.zinc600,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.zinc800 : AppColors.zinc200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$count",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.zinc200 : AppColors.zinc600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
