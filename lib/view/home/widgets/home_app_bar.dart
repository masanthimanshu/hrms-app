import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "/providers/auth_provider.dart";
import "/providers/health_provider.dart";
import "/utils/colors.dart";
import "/widgets/status_pill.dart";

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthProvider);
    final authState = ref.watch(authProvider);

    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.zinc950,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                "H",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "HRMS",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: AppColors.zinc950,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.zinc200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              "ENTERPRISE",
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.zinc700,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(
            child: StatusPill(
              label: healthState.status.isOnline ? "API Online" : "Connecting",
              type: healthState.status.isOnline
                  ? StatusPillType.active
                  : StatusPillType.warning,
            ),
          ),
        ),
        if (authState.currentUser != null) ...[
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.zinc200,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.zinc300, width: 1),
                ),
                child: Center(
                  child: Text(
                    authState.currentUser!.name.isNotEmpty
                        ? authState.currentUser!.name[0].toUpperCase()
                        : "U",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.zinc900,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        IconButton(
          icon: const Icon(Icons.logout, size: 20, color: AppColors.zinc700),
          tooltip: "Sign Out",
          onPressed: () {
            ref.read(authProvider.notifier).logout();
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.zinc200,
          height: 1,
        ),
      ),
    );
  }
}
