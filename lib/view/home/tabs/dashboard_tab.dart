import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "/models/store_model.dart";
import "/network/requests.dart";
import "/providers/attendance_provider.dart";
import "/providers/auth_provider.dart";
import "/providers/health_provider.dart";
import "/providers/store_provider.dart";
import "/utils/colors.dart";
import "/utils/formatters.dart";
import "/widgets/monochrome_button.dart";
import "/widgets/monochrome_card.dart";
import "/widgets/section_header.dart";
import "/widgets/stat_card.dart";
import "/widgets/status_pill.dart";

class DashboardTab extends ConsumerWidget {
  final Function(int) onNavigateTab;
  final VoidCallback onOpenAddStore;

  const DashboardTab({
    super.key,
    required this.onNavigateTab,
    required this.onOpenAddStore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final storeState = ref.watch(storeProvider);
    final attendanceState = ref.watch(attendanceProvider);
    final healthState = ref.watch(healthProvider);

    final currentUser = authState.currentUser;
    final userName = currentUser?.name ?? "Employee";
    final todayFormatted = AppFormatters.formatShortDate(DateTime.now());

    // Find assigned store
    StoreModel? assignedStore;
    if (storeState.stores.isNotEmpty) {
      assignedStore = storeState.stores.firstWhere(
        (s) => s.id == currentUser?.storeId,
        orElse: () => storeState.stores.first,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Banner
          MonochromeCard(
            backgroundColor: AppColors.zinc950,
            borderColor: AppColors.zinc800,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todayFormatted.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.zinc400,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Welcome back, $userName",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    StatusPill(
                      label: healthState.status.isOnline ? "API Online" : "Connecting",
                      type: healthState.status.isOnline
                          ? StatusPillType.active
                          : StatusPillType.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.storefront_outlined, size: 16, color: AppColors.zinc400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        assignedStore != null
                            ? "Assigned Facility: ${assignedStore.name}"
                            : "No store branch linked",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.zinc300,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bento KPI Metric Grid
          SectionHeader(
            title: "System Overview",
            subtitle: "Real-time metrics and personnel status",
            action: IconButton(
              icon: const Icon(Icons.refresh, size: 20, color: AppColors.zinc700),
              tooltip: "Refresh Metrics",
              onPressed: () {
                ref.read(storeProvider.notifier).loadStores();
                ref.read(healthProvider.notifier).checkHealth();
              },
            ),
          ),
          const SizedBox(height: 14),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              final crossAxisCount = isWide ? 4 : 2;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isWide ? 1.4 : 1.3,
                children: [
                  StatCard(
                    title: "Store Branches",
                    value: "${storeState.stores.length}",
                    subtitle: "Physical facilities cataloged",
                    icon: Icons.storefront,
                    trailing: GestureDetector(
                      onTap: () => onNavigateTab(1),
                      child: const Icon(Icons.arrow_forward, size: 16, color: AppColors.zinc500),
                    ),
                  ),
                  StatCard(
                    title: "Attendance",
                    value: attendanceState.hasCheckedInToday ? "Checked In" : "Pending",
                    subtitle: attendanceState.hasCheckedInToday
                        ? "Geo-verified today"
                        : "Action required",
                    icon: Icons.how_to_reg_outlined,
                    trailing: StatusPill(
                      label: attendanceState.hasCheckedInToday ? "Done" : "Pending",
                      type: attendanceState.hasCheckedInToday
                          ? StatusPillType.active
                          : StatusPillType.warning,
                      showDot: false,
                    ),
                  ),
                  StatCard(
                    title: "Session JWT",
                    value: "Active",
                    subtitle: "Dual-Token security valid",
                    icon: Icons.shield_outlined,
                    trailing: GestureDetector(
                      onTap: () => onNavigateTab(4),
                      child: const Icon(Icons.arrow_forward, size: 16, color: AppColors.zinc500),
                    ),
                  ),
                  StatCard(
                    title: "API Latency",
                    value: healthState.status.latencyMs > 0
                        ? "${healthState.status.latencyMs}ms"
                        : "Normal",
                    subtitle: "Cloudflare edge response",
                    icon: Icons.speed_outlined,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Quick Attendance Action Card
          SectionHeader(
            title: "Today's Attendance",
            subtitle: "Geo-tagged coordinate verification",
            action: TextButton(
              onPressed: () => onNavigateTab(3),
              child: const Text("View History"),
            ),
          ),
          const SizedBox(height: 12),

          MonochromeCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: attendanceState.hasCheckedInToday
                        ? AppColors.zinc100
                        : AppColors.zinc950,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    attendanceState.hasCheckedInToday
                        ? Icons.check_circle_outline
                        : Icons.pin_drop_outlined,
                    color: attendanceState.hasCheckedInToday
                        ? AppColors.zinc950
                        : AppColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attendanceState.hasCheckedInToday
                            ? "Attendance Logged For Today"
                            : "Daily Check-In Required",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.zinc950,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        attendanceState.hasCheckedInToday
                            ? "Verified at ${AppFormatters.formatDate(attendanceState.latestRecord?.timestamp)}"
                            : "Simulated GPS: ${attendanceState.currentLatitude}, ${attendanceState.currentLongitude}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.zinc500,
                        ),
                      ),
                    ],
                  ),
                ),
                MonochromeButton(
                  text: attendanceState.hasCheckedInToday ? "Checked In" : "Clock In",
                  onPressed: attendanceState.hasCheckedInToday
                      ? null
                      : () => onNavigateTab(3),
                  variant: attendanceState.hasCheckedInToday
                      ? MonochromeButtonVariant.ghost
                      : MonochromeButtonVariant.primary,
                  height: 40,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Quick Admin Actions
          const SectionHeader(
            title: "Quick Actions",
            subtitle: "Workforce and facility administrative shortcuts",
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: MonochromeButton(
                  text: "Add Store Branch",
                  icon: Icons.add_business_outlined,
                  variant: MonochromeButtonVariant.secondary,
                  onPressed: onOpenAddStore,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MonochromeButton(
                  text: "Onboard Employee",
                  icon: Icons.person_add_outlined,
                  variant: MonochromeButtonVariant.secondary,
                  onPressed: () => onNavigateTab(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Backend Live API Status Card
          MonochromeCard(
            padding: const EdgeInsets.all(18),
            backgroundColor: AppColors.zinc50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.cloud_outlined, size: 18, color: AppColors.zinc700),
                        SizedBox(width: 8),
                        Text(
                          "Live API Infrastructure",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.zinc950,
                          ),
                        ),
                      ],
                    ),
                    StatusPill(
                      label: healthState.status.isOnline ? "Healthy" : "Offline",
                      type: healthState.status.isOnline
                          ? StatusPillType.active
                          : StatusPillType.inactive,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Endpoints: /health, /account/store/*, /account/auth/*, /jwt/refresh, /secure/verify",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: "monospace",
                    color: AppColors.zinc600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Target Base: https://hrms.scoobies.ai/app/ • Header: account: ${kDefaultAccountId.substring(0, 8)}...",
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.zinc500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
