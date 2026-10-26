class AppFormatters {
  AppFormatters._();

  static const _months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  static DateTime? _parse(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date.toLocal();
    final parsed = DateTime.tryParse(date.toString());
    return parsed?.toLocal();
  }

  /// Format date to "22 Oct 2026, 14:30"
  static String formatDate(dynamic date) {
    final dt = _parse(date);
    if (dt == null) return "N/A";
    final d = dt.day.toString().padLeft(2, "0");
    final h = dt.hour.toString().padLeft(2, "0");
    final min = dt.minute.toString().padLeft(2, "0");
    return "$d ${_months[dt.month - 1]} ${dt.year}, $h:$min";
  }

  /// Format short date "22 Oct 2026"
  static String formatShortDate(dynamic date) {
    final dt = _parse(date);
    if (dt == null) return "N/A";
    return "${dt.day} ${_months[dt.month - 1]} ${dt.year}";
  }

  /// Format time "09:14 AM"
  static String formatTime(dynamic date) {
    final dt = _parse(date);
    if (dt == null) return "--:--";
    final hour = dt.hour;
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = hour >= 12 ? "PM" : "AM";
    final minute = dt.minute.toString().padLeft(2, "0");
    return "${displayHour.toString().padLeft(2, '0')}:$minute $period";
  }

  /// Format coordinates (e.g. "28.5136, 77.3739")
  static String formatCoordinates(
    String? lat,
    String? lng, {
    int decimals = 4,
  }) {
    if (lat == null || lng == null || lat.isEmpty || lng.isEmpty) {
      return "Unavailable";
    }
    final dLat = double.tryParse(lat)?.toStringAsFixed(decimals) ?? lat;
    final dLng = double.tryParse(lng)?.toStringAsFixed(decimals) ?? lng;
    return "$dLat, $dLng";
  }

  /// Truncate token for display
  static String maskToken(String? token, {int prefix = 8, int suffix = 8}) {
    if (token == null || token.isEmpty) return "None";
    if (token.length <= prefix + suffix + 3) return token;
    return "${token.substring(0, prefix)}...${token.substring(token.length - suffix)}";
  }

  /// Get initials from name ("Himanshu Masant" -> "HM")
  static String getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return "U";
    final parts = name.trim().split(RegExp(r"\s+"));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return "${parts[0][0]}${parts[1][0]}".toUpperCase();
  }
}
