import "package:flutter/material.dart";

import "/handler/session_handler.dart";

final Map<String, WidgetBuilder> appRoutes = {
  "/": (e) => const SessionHandler(),
};
