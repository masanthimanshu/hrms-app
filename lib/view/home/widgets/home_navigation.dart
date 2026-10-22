import "package:flutter/material.dart";

import "/utils/colors.dart";

class HomeNavigation {
  HomeNavigation._();

  static const List<NavigationRailDestination> railDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.camera_alt_outlined),
      selectedIcon: Icon(Icons.camera_alt),
      label: Text("Punch In"),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history),
      label: Text("History"),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: Text("Profile"),
    ),
  ];

  static const List<BottomNavigationBarItem> bottomNavItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.camera_alt_outlined),
      activeIcon: Icon(Icons.camera_alt),
      label: "Punch In",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.history_outlined),
      activeIcon: Icon(Icons.history),
      label: "History",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: "Profile",
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
