import "package:flutter/material.dart";

import "/utils/colors.dart";

class HomeNavigation {
  HomeNavigation._();

  static const List<NavigationRailDestination> railDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: Text("Overview"),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.storefront_outlined),
      selectedIcon: Icon(Icons.storefront),
      label: Text("Branches"),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.badge_outlined),
      selectedIcon: Icon(Icons.badge),
      label: Text("Directory"),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.how_to_reg_outlined),
      selectedIcon: Icon(Icons.how_to_reg),
      label: Text("Attendance"),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.shield_outlined),
      selectedIcon: Icon(Icons.shield),
      label: Text("Security"),
    ),
  ];

  static const List<BottomNavigationBarItem> bottomNavItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard),
      label: "Overview",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.storefront_outlined),
      activeIcon: Icon(Icons.storefront),
      label: "Branches",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.badge_outlined),
      activeIcon: Icon(Icons.badge),
      label: "Directory",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.how_to_reg_outlined),
      activeIcon: Icon(Icons.how_to_reg),
      label: "Attendance",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shield_outlined),
      activeIcon: Icon(Icons.shield),
      label: "Security",
    ),
  ];
}

class HomeBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.zinc200, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.zinc950,
        unselectedItemColor: AppColors.zinc400,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        elevation: 0,
        items: HomeNavigation.bottomNavItems,
      ),
    );
  }
}
