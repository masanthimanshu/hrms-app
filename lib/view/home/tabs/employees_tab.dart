import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "/models/user_model.dart";
import "/providers/auth_provider.dart";
import "/providers/store_provider.dart";
import "/utils/colors.dart";
import "/view/home/widgets/employee_card.dart";
import "/widgets/empty_state.dart";
import "/widgets/monochrome_button.dart";
import "/widgets/section_header.dart";

class EmployeesTab extends ConsumerStatefulWidget {
  final VoidCallback onOpenOnboard;

  const EmployeesTab({
    super.key,
    required this.onOpenOnboard,
  });

  @override
  ConsumerState<EmployeesTab> createState() => _EmployeesTabState();
}

class _EmployeesTabState extends ConsumerState<EmployeesTab> {
  String _selectedStoreFilter = "ALL";
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final storeState = ref.watch(storeProvider);

    // Build directory list with current authenticated user and seed records
    final List<UserModel> directory = [
      if (authState.currentUser != null) authState.currentUser!,
      UserModel(
        id: "emp-201",
        name: "Elena Rostova",
        email: "elena.rostova@example.com",
        storeId: storeState.stores.isNotEmpty ? storeState.stores.first.id : "store-1",
        storeName: storeState.stores.isNotEmpty ? storeState.stores.first.name : "Headquarters",
        isValid: true,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      UserModel(
        id: "emp-202",
        name: "Marcus Vance",
        email: "marcus.vance@example.com",
        storeId: storeState.stores.isNotEmpty ? storeState.stores.first.id : "store-1",
        storeName: storeState.stores.isNotEmpty ? storeState.stores.first.name : "Headquarters",
        isValid: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];

    final filtered = directory.where((emp) {
      final matchesSearch = emp.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          emp.email.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_selectedStoreFilter == "ALL") return matchesSearch;
      return matchesSearch && emp.storeId == _selectedStoreFilter;
    }).toList();

    return Column(
      children: [
        // Top Toolbar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: "Employee Directory",
                subtitle: "${directory.length} personnel registered across branches",
                action: MonochromeButton(
                  text: "Onboard",
                  icon: Icons.person_add_outlined,
                  onPressed: widget.onOpenOnboard,
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ),
              const SizedBox(height: 14),

              // Search Box
              TextFormField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontSize: 14, color: AppColors.zinc900),
                decoration: const InputDecoration(
                  hintText: "Search employee by name or email...",
                  prefixIcon: Icon(Icons.search, size: 18, color: AppColors.zinc500),
                ),
              ),
              const SizedBox(height: 12),

              // Branch Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      selected: _selectedStoreFilter == "ALL",
                      label: const Text("All Branches"),
                      selectedColor: AppColors.zinc950,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _selectedStoreFilter == "ALL" ? AppColors.white : AppColors.zinc800,
                      ),
                      onSelected: (_) => setState(() => _selectedStoreFilter = "ALL"),
                    ),
                    const SizedBox(width: 8),
                    ...storeState.stores.map((s) {
                      final isSelected = _selectedStoreFilter == s.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(s.name),
                          selectedColor: AppColors.zinc950,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.white : AppColors.zinc800,
                          ),
                          onSelected: (_) => setState(() => _selectedStoreFilter = s.id),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Employees List
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(
                  icon: Icons.badge_outlined,
                  title: "No employees found",
                  description: "No personnel match your search filters.",
                  buttonText: "Reset Filters",
                  onButtonPressed: () => setState(() {
                    _searchQuery = "";
                    _selectedStoreFilter = "ALL";
                  }),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final emp = filtered[index];
                    return EmployeeCard(
                      employee: emp,
                      isCurrentUser: emp.email == authState.currentUser?.email,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
