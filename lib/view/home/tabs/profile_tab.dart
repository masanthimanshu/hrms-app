import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "/models/store_model.dart";
import "/providers/auth_provider.dart";
import "/providers/store_provider.dart";
import "/utils/colors.dart";
import "/utils/formatters.dart";
import "/widgets/monochrome_button.dart";
import "/widgets/monochrome_card.dart";
import "/widgets/section_header.dart";
import "/widgets/status_pill.dart";

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  bool _isVerifying = false;
  String? _verifyMessage;

  void _testVerify() async {
    setState(() => _isVerifying = true);
    final isValid = await ref.read(authProvider.notifier).verifySession();
    setState(() {
      _isVerifying = false;
      _verifyMessage = isValid
          ? "Session signature cryptographically verified with backend!"
          : "Session verification failed.";
    });
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Sign Out",
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.zinc950),
        ),
        content: const Text(
          "Are you sure you want to sign out of your employee account?",
          style: TextStyle(fontSize: 14, color: AppColors.zinc600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          MonochromeButton(
            text: "Sign Out",
            height: 38,
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final storeState = ref.watch(storeProvider);

    final currentUser = authState.currentUser;
    final userName = currentUser?.name ?? "Alex Vance";
    final email = currentUser?.email ?? "alex.vance@example.com";

    StoreModel? assignedStore;
    if (storeState.stores.isNotEmpty) {
      assignedStore = storeState.stores.firstWhere(
        (s) => s.id == currentUser?.storeId,
        orElse: () => storeState.stores.first,
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: "Employee Profile",
            subtitle: "Personal account credentials & workplace details",
          ),
          const SizedBox(height: 16),

          // Profile Header Card
          MonochromeCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.zinc950,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.zinc800, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      AppFormatters.getInitials(userName),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.zinc950,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.zinc600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const StatusPill(
                        label: "Active Personnel",
                        type: StatusPillType.active,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Workplace Facility Card
          MonochromeCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Assigned Work Facility",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.zinc950,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.storefront_outlined, size: 18, color: AppColors.zinc700),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignedStore?.name ?? "Primary Branch",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.zinc900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            assignedStore?.address ?? "Facility Address",
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.zinc600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Coordinates: ${assignedStore?.latitude ?? '37.7892'}, ${assignedStore?.longitude ?? '-122.3982'}",
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: "monospace",
                              color: AppColors.zinc500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Session & Security Status
          MonochromeCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Dual-Token Session Status",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zinc950,
                      ),
                    ),
                    StatusPill(label: "JWT Active", type: StatusPillType.active),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Access Token: ${AppFormatters.maskToken(authState.authToken, prefix: 6, suffix: 6)}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: "monospace",
                    color: AppColors.zinc600,
                  ),
                ),
                const SizedBox(height: 12),
                if (_verifyMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.zinc100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.zinc300, width: 1),
                    ),
                    child: Text(
                      _verifyMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.zinc950,
                      ),
                    ),
                  ),
                ],
                MonochromeButton(
                  text: "Verify Security Signature",
                  icon: Icons.shield_outlined,
                  variant: MonochromeButtonVariant.secondary,
                  isLoading: _isVerifying,
                  height: 40,
                  onPressed: _testVerify,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sign Out Action
          MonochromeButton(
            text: "Sign Out",
            icon: Icons.logout,
            variant: MonochromeButtonVariant.ghost,
            height: 44,
            onPressed: _confirmSignOut,
          ),
        ],
      ),
    );
  }
}
