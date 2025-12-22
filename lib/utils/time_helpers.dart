class TimeHelpers {
  static String formatMinutes(int minutes) {
    if (minutes < 60) {
      return "$minutes min";
    }

    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return "${hours}h";
    }

    return "${hours}h ${remainingMinutes}m";
  }

  static String getTimeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) {
      return "just now";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hours ago";
    } else if (diff.inDays <= 5) {
      return "${diff.inDays} days ago";
    } else if (diff.inDays < 365) {
      final int months = diff.inDays ~/ 30;
      return "${months <= 1 ? 1 : months} months ago";
    } else {
      final int years = diff.inDays ~/ 365;
      return "${years == 1 ? 1 : years} years ago";
    }
  }
}
