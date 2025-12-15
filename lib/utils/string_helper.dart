class StringHelper {
  static bool hasMinConsecutiveMatch(
    String a,
    String b, {
    int minLength = 3,
  }) {
    if (a.length < minLength || b.length < minLength) return false;

    final short = a.length <= b.length ? a : b;
    final long = a.length <= b.length ? b : a;

    for (int i = 0; i <= short.length - minLength; i++) {
      final substring = short.substring(i, i + minLength);
      if (long.contains(substring)) {
        return true;
      }
    }
    return false;
  }
}
