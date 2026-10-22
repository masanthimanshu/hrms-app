import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "/providers/health_provider.dart";
import "/utils/colors.dart";
import "/widgets/monochrome_card.dart";
import "/widgets/status_pill.dart";
import "login_view.dart";
import "register_view.dart";

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _selectedTab = 0; // 0 for Login, 1 for Register

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(healthProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand Header
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.zinc950,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.zinc800, width: 1.5),
                      ),
                      child: const Center(
                        child: Text(
                          "H",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "HRMS Portal",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.zinc950,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Enterprise Workforce, Facility & Attendance System",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.zinc500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Segmented Monochrome Tab Switcher
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.zinc200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTab == 0
                                    ? AppColors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _selectedTab == 0
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x10000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                "Sign In",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _selectedTab == 0
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: _selectedTab == 0
                                      ? AppColors.zinc950
                                      : AppColors.zinc600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1
                                    ? AppColors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _selectedTab == 1
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x10000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                "Register Employee",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _selectedTab == 1
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: _selectedTab == 1
                                      ? AppColors.zinc950
                                      : AppColors.zinc600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Auth Card Container
                  MonochromeCard(
                    padding: const EdgeInsets.all(24),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _selectedTab == 0
                          ? LoginView(
                              key: const ValueKey("login"),
                              onSwitchToRegister: () =>
                                  setState(() => _selectedTab = 1),
                            )
                          : RegisterView(
                              key: const ValueKey("register"),
                              onSwitchToLogin: () =>
                                  setState(() => _selectedTab = 0),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Server Connection Status Footer
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      StatusPill(
                        label: healthState.status.isOnline
                            ? "Live API Connected"
                            : "Connecting to API...",
                        type: healthState.status.isOnline
                            ? StatusPillType.active
                            : StatusPillType.warning,
                      ),
                      const Text(
                        "Express 5 • JWT Dual-Token",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.zinc400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
