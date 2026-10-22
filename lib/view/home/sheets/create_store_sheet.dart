import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "/providers/store_provider.dart";
import "/utils/colors.dart";
import "/widgets/monochrome_button.dart";
import "/widgets/monochrome_text_field.dart";

class CreateStoreSheet extends ConsumerStatefulWidget {
  const CreateStoreSheet({super.key});

  @override
  ConsumerState<CreateStoreSheet> createState() => _CreateStoreSheetState();
}

class _CreateStoreSheetState extends ConsumerState<CreateStoreSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latController = TextEditingController(text: "37.7892");
  final _lngController = TextEditingController(text: "-122.3982");
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _usePresetCoordinates(String name, String address, String lat, String lng) {
    setState(() {
      _nameController.text = name;
      _addressController.text = address;
      _latController.text = lat;
      _lngController.text = lng;
    });
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      final success = await ref.read(storeProvider.notifier).createStore(
            name: _nameController.text,
            address: _addressController.text,
            latitude: _latController.text,
            longitude: _lngController.text,
          );
      setState(() => _isSubmitting = false);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Branch '${_nameController.text}' registered!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                "Register Store Branch",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.zinc950,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Add a physical facility for geo-verified workforce tracking",
                style: TextStyle(fontSize: 13, color: AppColors.zinc500),
              ),
              const SizedBox(height: 18),

              // Preset helpers
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text("NYC Hub", style: TextStyle(fontSize: 12)),
                    onPressed: () => _usePresetCoordinates(
                      "Manhattan Operations Hub",
                      "350 5th Ave, New York, NY",
                      "40.7484",
                      "-73.9857",
                    ),
                  ),
                  ActionChip(
                    label: const Text("London HQ", style: TextStyle(fontSize: 12)),
                    onPressed: () => _usePresetCoordinates(
                      "London Tech Center",
                      "100 Bishopsgate, London, UK",
                      "51.5152",
                      "-0.0818",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              MonochromeTextField(
                controller: _nameController,
                label: "Branch Name",
                hintText: "e.g. Downtown Logistics Facility",
                validator: (v) => (v == null || v.trim().isEmpty) ? "Enter branch name" : null,
              ),
              const SizedBox(height: 14),
              MonochromeTextField(
                controller: _addressController,
                label: "Physical Address",
                hintText: "Street address, City, Region",
                validator: (v) => (v == null || v.trim().isEmpty) ? "Enter address" : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: MonochromeTextField(
                      controller: _latController,
                      label: "Latitude",
                      hintText: "37.7749",
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MonochromeTextField(
                      controller: _lngController,
                      label: "Longitude",
                      hintText: "-122.4194",
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              MonochromeButton(
                text: "Create Store Branch",
                onPressed: _submit,
                isLoading: _isSubmitting,
                icon: Icons.check,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
