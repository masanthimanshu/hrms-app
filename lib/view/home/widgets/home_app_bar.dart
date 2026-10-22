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
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.zinc950,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Text(
                "H",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "HRMS",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: AppColors.zinc950,
            ),
          ),
        ],
      ),
      actions: [
        Center(
          child: StatusPill(
            label: healthState.status.isOnline ? "Live" : "Offline",
            type: healthState.status.isOnline
                ? StatusPillType.active
                : StatusPillType.warning,
          ),
        ),
        if (authState.currentUser != null) ...[
          const SizedBox(width: 8),
          Center(
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
        ],
        IconButton(
          icon: const Icon(Icons.logout, size: 18, color: AppColors.zinc700),
          tooltip: "Sign Out",
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
          onPressed: () {
            ref.read(authProvider.notifier).logout();
          },
        ),
        const SizedBox(width: 12),
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
