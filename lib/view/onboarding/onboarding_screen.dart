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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: "alex.vance@example.com");
  final _passwordController = TextEditingController(text: "Password123!");
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(authProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );
    }
  }

  void _fillDemoCredentials() {
    setState(() {
      _emailController.text = "alex.vance@example.com";
      _passwordController.text = "Password123!";
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final healthState = ref.watch(healthProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewportConstraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight - 48,
                ),
                child: IntrinsicHeight(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // App Icon & Branding
                            Center(
                              child: Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: AppColors.zinc950,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.zinc800,
                                    width: 1.5,
                                  ),
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
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: AppColors.zinc500,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Error Message Banner
                            if (authState.errorMessage != null) ...[
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
                            ],

                            // Login Card Container
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
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  MonochromeTextField(
                                    controller: _emailController,
                                    label: "Work Email",
                                    hintText: "employee@example.com",
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: const Icon(
                                      Icons.mail_outline,
                                      size: 18,
                                      color: AppColors.zinc500,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return "Enter your corporate email";
                                      }
                                      if (!v.contains("@")) {
                                        return "Enter a valid email address";
                                      }
                                      return null;
                                    },
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
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return "Enter your password";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _fillDemoCredentials,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        "Fill Demo Account (Alex Vance)",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.zinc600,
                                          decoration: TextDecoration.underline,
                                        ),
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

                            // Note for non-registered employees
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.zinc100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.zinc200,
                                  width: 1,
                                ),
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
                                      "Employee-only application. Contact your company administrator to obtain login credentials.",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.zinc600,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Server Connection Status Footer
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                StatusPill(
                                  label: healthState.status.isOnline
                                      ? "API Connected"
                                      : "Connecting...",
                                  type: healthState.status.isOnline
                                      ? StatusPillType.active
                                      : StatusPillType.warning,
                                ),
                                const Text(
                                  "Dual-Token Verified Security",
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
              ),
            );
          },
        ),
      ),
    );
  }
}
