import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "/providers/attendance_provider.dart";
import "/utils/colors.dart";
import "/view/home/widgets/attendance_log_tile.dart";
import "/widgets/empty_state.dart";
import "/widgets/section_header.dart";
import "/widgets/stat_card.dart";

class HistoryTab extends ConsumerWidget {
  final VoidCallback onNavigateToPunch;

  const HistoryTab({
    super.key,
    required this.onNavigateToPunch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceProvider);
    final records = attendanceState.records;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: "Attendance History",
            subtitle: "Personal punch-in timesheet & audit log",
          ),
          const SizedBox(height: 16),

          // Monthly Summary Stats
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: "Days Logged",
                  value: "${records.length}",
                  subtitle: "Recorded check-ins",
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: StatCard(
                  title: "Verification",
                  value: "100%",
                  subtitle: "Geofence matched",
                  icon: Icons.verified_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SectionHeader(
            title: "Check-In Logs",
            subtitle: "Historical timestamps & photo verification proofs",
            action: Text(
              "${records.length} Logs",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.zinc500,
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (records.isEmpty)
            EmptyState(
              icon: Icons.access_time_outlined,
              title: "No attendance logs yet",
              description: "Clock in using your camera to create your first attendance record.",
              buttonText: "Go to Punch In",
              onButtonPressed: onNavigateToPunch,
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final record = records[index];
                return AttendanceLogTile(record: record);
              },
            ),
        ],
      ),
    );
  }
}
