import "package:flutter/material.dart";

import "/utils/colors.dart";
import "tabs/attendance_tab.dart";
import "tabs/history_tab.dart";
import "tabs/profile_tab.dart";
import "widgets/home_app_bar.dart";
import "widgets/home_navigation.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      AttendanceTab(
        onNavigateToHistory: () => setState(() => _currentTabIndex = 1),
      ),
      HistoryTab(onNavigateToPunch: () => setState(() => _currentTabIndex = 0)),
      const ProfileTab(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: const HomeAppBar(),
          body: isDesktop
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _currentTabIndex,
                      onDestinationSelected: (index) =>
                          setState(() => _currentTabIndex = index),
                      backgroundColor: AppColors.white,
                      minWidth: 72,
                      labelType: NavigationRailLabelType.all,
                      selectedIconTheme: const IconThemeData(
                        color: AppColors.zinc950,
                        size: 22,
                      ),
                      unselectedIconTheme: const IconThemeData(
                        color: AppColors.zinc500,
                        size: 22,
                      ),
                      selectedLabelTextStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zinc950,
                      ),
                      unselectedLabelTextStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.zinc500,
                      ),
                      destinations: HomeNavigation.railDestinations,
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: AppColors.zinc200,
                    ),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: tabs[_currentTabIndex],
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: tabs[_currentTabIndex],
                  ),
                ),
          bottomNavigationBar: isDesktop
              ? null
              : HomeBottomBar(
                  currentIndex: _currentTabIndex,
                  onTap: (index) => setState(() => _currentTabIndex = index),
                ),
        );
      },
    );
  }
}
