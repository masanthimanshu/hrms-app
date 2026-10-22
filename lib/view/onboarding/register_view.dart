import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "/providers/auth_provider.dart";
import "/providers/store_provider.dart";
import "/utils/colors.dart";
import "/widgets/monochrome_button.dart";
import "/widgets/monochrome_text_field.dart";

class RegisterView extends ConsumerStatefulWidget {
  final VoidCallback onSwitchToLogin;

  const RegisterView({
    super.key,
    required this.onSwitchToLogin,
  });

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: "Alex Mercer");
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: "SuperSecretPassword123!");
  String? _selectedStoreId;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final randomId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    _emailController.text = "alex.mercer.$randomId@example.com";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_selectedStoreId == null || _selectedStoreId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a store branch")),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authProvider.notifier).register(
            name: _nameController.text,
            email: _emailController.text,
            storeId: _selectedStoreId!,
            password: _passwordController.text,
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful! Please sign in.")),
        );
        widget.onSwitchToLogin();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final storeState = ref.watch(storeProvider);

    // Default select first store if available and not yet set
    if (_selectedStoreId == null && storeState.stores.isNotEmpty) {
      _selectedStoreId = storeState.stores.first.id;
    }

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
          MonochromeTextField(
            controller: _nameController,
            label: "Full Name",
            hintText: "e.g. Alex Mercer",
            prefixIcon: const Icon(Icons.person_outline, size: 18, color: AppColors.zinc500),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return "Enter employee name";
              return null;
            },
          ),
          const SizedBox(height: 16),
          MonochromeTextField(
            controller: _emailController,
            label: "Work Email",
            hintText: "alex.mercer@example.com",
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.mail_outline, size: 18, color: AppColors.zinc500),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return "Enter email address";
              if (!v.contains("@")) return "Enter a valid email address";
              return null;
            },
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Assigned Store Branch",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.zinc800,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 6),
              storeState.isLoading && storeState.stores.isEmpty
                  ? Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.zinc200, width: 1),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text("Loading physical branches...", style: TextStyle(fontSize: 13, color: AppColors.zinc500)),
                        ],
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.zinc200, width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStoreId,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.zinc600),
                          hint: const Text(
                            "Select Store Branch",
                            style: TextStyle(fontSize: 14, color: AppColors.zinc400),
                          ),
                          items: storeState.stores.map((s) {
                            return DropdownMenuItem<String>(
                              value: s.id,
                              child: Text(
                                s.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.zinc900,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedStoreId = val);
                          },
                        ),
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 16),
          MonochromeTextField(
            controller: _passwordController,
            label: "Create Password",
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
              if (v == null || v.trim().isEmpty) return "Enter password";
              if (v.length < 6) return "Password must be at least 6 characters";
              return null;
            },
          ),
          const SizedBox(height: 24),
          MonochromeButton(
            text: "Register Employee",
            onPressed: _submit,
            isLoading: authState.isLoading,
            icon: Icons.person_add_outlined,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Already registered? ",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.zinc500,
                ),
              ),
              GestureDetector(
                onTap: widget.onSwitchToLogin,
                child: const Text(
                  "Sign In",
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
