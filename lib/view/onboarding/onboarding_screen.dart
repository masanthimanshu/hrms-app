import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "/providers/auth_provider.dart";
import "/providers/health_provider.dart";
import "/utils/colors.dart";
import "/widgets/monochrome_button.dart";
import "/widgets/monochrome_card.dart";
import "/widgets/monochrome_text_field.dart";
import "/widgets/status_pill.dart";

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
      return;
    }
    ref.read(authProvider.notifier).login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final healthState = ref.watch(healthProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon & Branding
                  Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.zinc950,
                        borderRadius: BorderRadius.circular(14),
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
                  const SizedBox(height: 14),
                  const Text(
                    "Employee HRMS",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.zinc950,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Daily Attendance & Selfie Geo-Verification",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.zinc500),
                  ),
                  const SizedBox(height: 24),

                  // Error Banner
                  if (authState.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.zinc100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.zinc800,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 16,
                            color: AppColors.zinc950,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authState.errorMessage!,
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

                  // Login Card
                  MonochromeCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.zinc950,
                          ),
                        ),
                        const SizedBox(height: 14),
                        MonochromeTextField(
                          controller: _emailController,
                          label: "Work Email",
                          hintText: "name@company.com",
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(
                            Icons.mail_outline,
                            size: 18,
                            color: AppColors.zinc500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        MonochromeTextField(
                          controller: _passwordController,
                          label: "Password",
                          hintText: "••••••••",
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            size: 18,
                            color: AppColors.zinc500,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: AppColors.zinc600,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        MonochromeButton(
                          text: "Sign In & Open Scanner",
                          onPressed: _submit,
                          isLoading: authState.isLoading,
                          icon: Icons.login,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Employee Note
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.zinc100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.zinc200, width: 1),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 15,
                          color: AppColors.zinc600,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Employee-only app. Contact your administrator for credentials.",
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.zinc600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status Footer
                  Center(
                    child: StatusPill(
                      label: healthState.status.isOnline
                          ? "API Connected"
                          : "Connecting...",
                      type: healthState.status.isOnline
                          ? StatusPillType.active
                          : StatusPillType.warning,
                    ),
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
