import "package:flutter/material.dart";

import "/handler/session_handler.dart";
import "/view/home/home_screen.dart";
import "/view/onboarding/onboarding_screen.dart";
import "/view/splash/splash_screen.dart";

class AppRoutes {
  AppRoutes._();

  static const String root = "/";
  static const String home = "/home";
  static const String onboarding = "/onboarding";
  static const String splash = "/splash";
}

final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.root: (context) => const SessionHandler(),
  AppRoutes.home: (context) => const HomeScreen(),
  AppRoutes.onboarding: (context) => const OnboardingScreen(),
  AppRoutes.splash: (context) => const SplashScreen(),
};
