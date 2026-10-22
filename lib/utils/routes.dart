import "package:flutter/material.dart";

import "/handler/session_handler.dart";
import "/view/view.dart";

/// Named route path constants
class AppRoutes {
  AppRoutes._();

  static const String root = "/";
  static const String home = "/home";
  static const String onboarding = "/onboarding";
  static const String splash = "/splash";
}

/// Central application route table
final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.root: (context) => const SessionHandler(),
  AppRoutes.home: (context) => const HomeScreen(),
  AppRoutes.onboarding: (context) => const OnboardingScreen(),
  AppRoutes.splash: (context) => const SplashScreen(),
};
