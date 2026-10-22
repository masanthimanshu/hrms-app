import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "/providers/store_provider.dart";
import "/utils/colors.dart";
import "/view/home/widgets/store_card.dart";
import "/widgets/empty_state.dart";
import "/widgets/monochrome_button.dart";
import "/widgets/section_header.dart";

class StoresTab extends ConsumerWidget {
  final VoidCallback onOpenAddStore;

  const StoresTab({
    super.key,
    required this.onOpenAddStore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeState = ref.watch(storeProvider);
    final stores = storeState.filteredStores;

    return Column(
      children: [
        // Top Toolbar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: "Store Branches",
                subtitle: "${storeState.stores.length} physical facilities registered",
                action: MonochromeButton(
                  text: "Add Branch",
                  icon: Icons.add,
                  onPressed: onOpenAddStore,
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ),
              const SizedBox(height: 14),
              // Search Field
              TextFormField(
                initialValue: storeState.searchQuery,
                onChanged: (val) => ref.read(storeProvider.notifier).setSearchQuery(val),
                style: const TextStyle(fontSize: 14, color: AppColors.zinc900),
                decoration: InputDecoration(
                  hintText: "Search branch by name or address...",
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.zinc500),
                  suffixIcon: storeState.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 16, color: AppColors.zinc500),
                          onPressed: () => ref.read(storeProvider.notifier).setSearchQuery(""),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),

        // List / Empty State
        Expanded(
          child: storeState.isLoading && storeState.stores.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.zinc950),
                  ),
                )
              : stores.isEmpty
                  ? EmptyState(
                      icon: Icons.storefront_outlined,
                      title: storeState.searchQuery.isNotEmpty
                          ? "No matching branches"
                          : "No store branches yet",
                      description: storeState.searchQuery.isNotEmpty
                          ? "Try searching for a different branch name or address."
                          : "Register your first organizational store branch using the button below.",
                      buttonText: storeState.searchQuery.isNotEmpty ? "Clear Search" : "Add Branch",
                      onButtonPressed: storeState.searchQuery.isNotEmpty
                          ? () => ref.read(storeProvider.notifier).setSearchQuery("")
                          : onOpenAddStore,
                    )
                  : RefreshIndicator(
                      color: AppColors.zinc950,
                      onRefresh: () => ref.read(storeProvider.notifier).loadStores(),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        itemCount: stores.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final store = stores[index];
                          return StoreCard(store: store);
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
