import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "/providers/auth_provider.dart";
import "/providers/store_provider.dart";
import "/utils/colors.dart";
import "/widgets/monochrome_button.dart";
import "/widgets/monochrome_text_field.dart";

class OnboardEmployeeSheet extends ConsumerStatefulWidget {
  const OnboardEmployeeSheet({super.key});

  @override
  ConsumerState<OnboardEmployeeSheet> createState() => _OnboardEmployeeSheetState();
}

class _OnboardEmployeeSheetState extends ConsumerState<OnboardEmployeeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: "SuperSecretPassword123!");
  String? _selectedStoreId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(9);
    _nameController.text = "Jordan Blake";
    _emailController.text = "jordan.blake.$random@example.com";
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
        const SnackBar(content: Text("Please select a store branch for this employee")),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      final success = await ref.read(authProvider.notifier).register(
            name: _nameController.text,
            email: _emailController.text,
            storeId: _selectedStoreId!,
            password: _passwordController.text,
          );
      setState(() => _isSubmitting = false);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Employee '${_nameController.text}' successfully onboarded!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeState = ref.watch(storeProvider);

    if (_selectedStoreId == null && storeState.stores.isNotEmpty) {
      _selectedStoreId = storeState.stores.first.id;
    }

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.zinc300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Onboard New Employee",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.zinc950,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Registers credentials via POST /account/auth/create",
                style: TextStyle(fontSize: 13, color: AppColors.zinc500),
              ),
              const SizedBox(height: 18),

              MonochromeTextField(
                controller: _nameController,
                label: "Full Name",
                hintText: "e.g. Jordan Blake",
                validator: (v) => (v == null || v.trim().isEmpty) ? "Enter full name" : null,
              ),
              const SizedBox(height: 14),
              MonochromeTextField(
                controller: _emailController,
                label: "Corporate Email",
                hintText: "jordan.blake@example.com",
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains("@")) ? "Enter valid email" : null,
              ),
              const SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Branch Facility Assignment",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.zinc800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
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
                        items: storeState.stores.map((s) {
                          return DropdownMenuItem<String>(
                            value: s.id,
                            child: Text(s.name, style: const TextStyle(fontSize: 14, color: AppColors.zinc900)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedStoreId = val),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              MonochromeTextField(
                controller: _passwordController,
                label: "Initial Password",
                hintText: "••••••••",
                validator: (v) => (v == null || v.length < 6) ? "Minimum 6 characters" : null,
              ),
              const SizedBox(height: 24),
              MonochromeButton(
                text: "Complete Onboarding",
                onPressed: _submit,
                isLoading: _isSubmitting,
                icon: Icons.person_add_alt_1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
