import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "/providers/auth_provider.dart";
import "/view/home/home_screen.dart";
import "/view/onboarding/onboarding_screen.dart";
import "/view/splash/splash_screen.dart";

class SessionHandler extends ConsumerWidget {
  const SessionHandler({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading && authState.authToken == null) {
      return const SplashScreen();
    }

    if (authState.isAuthenticated) {
      return const HomeScreen();
    }

    return const OnboardingScreen();
  }
}
