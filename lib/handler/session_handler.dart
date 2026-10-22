import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "/network/endpoints.dart";
import "/network/requests.dart";
import "/view/home/home_screen.dart";
import "/view/onboarding/onboarding_screen.dart";
import "/view/splash/splash_screen.dart";

class SessionHandler extends ConsumerWidget {
  const SessionHandler({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = ref.watch(_provider);

    if (!res.hasValue) return const SplashScreen();

    if (res.value!) return const HomeScreen();

    return const OnboardingScreen();
  }
}

final _provider = FutureProvider((ref) => _Controller().checkToken());

class _Controller with HTTPRequests {
  Future<bool> checkToken() async {
    final res = await getRequest(apiEndpoint(ApiEndpoints.verifyToken));
    return res != null;
  }
}
