import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "/providers/auth_provider.dart";
import "/utils/colors.dart";
import "/widgets/monochrome_button.dart";
import "/widgets/monochrome_text_field.dart";

class LoginView extends ConsumerStatefulWidget {
  final VoidCallback onSwitchToRegister;

  const LoginView({
    super.key,
    required this.onSwitchToRegister,
  });

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
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

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (authState.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.zinc100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.zinc800, width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 18, color: AppColors.zinc950),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      authState.errorMessage!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.zinc950,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (authState.successMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.zinc100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.zinc300, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 18, color: AppColors.zinc950),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      authState.successMessage!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.zinc950,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          MonochromeTextField(
            controller: _emailController,
            label: "Work Email",
            hintText: "name@company.com",
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.mail_outline, size: 18, color: AppColors.zinc500),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return "Enter your email";
              if (!v.contains("@")) return "Enter a valid email address";
              return null;
            },
          ),
          const SizedBox(height: 16),
          MonochromeTextField(
            controller: _passwordController,
            label: "Password",
            hintText: "••••••••",
            obscureText: _obscurePassword,
            prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.zinc500),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18,
                color: AppColors.zinc600,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return "Enter your password";
              if (v.length < 6) return "Password must be at least 6 characters";
              return null;
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _fillDemoCredentials,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                "Use Demo Credentials (Alex Vance)",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.zinc600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          MonochromeButton(
            text: "Sign In",
            onPressed: _submit,
            isLoading: authState.isLoading,
            icon: Icons.arrow_forward,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Need to register a new employee? ",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.zinc500,
                ),
              ),
              GestureDetector(
                onTap: widget.onSwitchToRegister,
                child: const Text(
                  "Onboard here",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.zinc950,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
