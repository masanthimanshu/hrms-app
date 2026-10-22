/// Helper formatting utilities for timestamps, coordinates, and tokens
class AppFormatters {
  AppFormatters._();

  /// Format ISO string or DateTime to clean human-readable string
  static String formatDate(dynamic date) {
    if (date == null) return "N/A";
    try {
      final DateTime dt = date is DateTime ? date : DateTime.parse(date.toString());
      final List<String> months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      final String month = months[dt.month - 1];
      final String day = dt.day.toString().padLeft(2, "0");
      final String year = dt.year.toString();
      final String hour = dt.hour.toString().padLeft(2, "0");
      final String minute = dt.minute.toString().padLeft(2, "0");
      return "$day $month $year, $hour:$minute";
    } catch (_) {
      return date.toString();
    }
  }

  /// Format short date (e.g. 22 Oct 2026)
  static String formatShortDate(dynamic date) {
    if (date == null) return "N/A";
    try {
      final DateTime dt = date is DateTime ? date : DateTime.parse(date.toString());
      final List<String> months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
    } catch (_) {
      return date.toString();
    }
  }

  /// Format time only (e.g. 09:14 AM)
  static String formatTime(dynamic date) {
    if (date == null) return "--:--";
    try {
      final DateTime dt = date is DateTime ? date : DateTime.parse(date.toString());
      final int hour = dt.hour;
      final int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final String period = hour >= 12 ? "PM" : "AM";
      final String minute = dt.minute.toString().padLeft(2, "0");
      return "${displayHour.toString().padLeft(2, '0')}:$minute $period";
    } catch (_) {
      return "--:--";
    }
  }

  /// Format coordinates (e.g. 37.7892, -122.3982)
  static String formatCoordinates(String? lat, String? lng) {
    if (lat == null || lng == null || lat.isEmpty || lng.isEmpty) {
      return "Unavailable";
    }
    return "$lat° N, $lng° W";
  }

  /// Truncate long JWT or ID token for clean display
  static String maskToken(String? token, {int prefix = 8, int suffix = 8}) {
    if (token == null || token.isEmpty) return "None";
    if (token.length <= prefix + suffix + 3) return token;
    return "${token.substring(0, prefix)}...${token.substring(token.length - suffix)}";
  }

  /// Get initials from name (e.g. "Alex Vance" -> "AV")
  static String getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return "U";
    final parts = name.trim().split(RegExp(r"\s+"));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return "${parts[0][0]}${parts[1][0]}".toUpperCase();
  }
}
