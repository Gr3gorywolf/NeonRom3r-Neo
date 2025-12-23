enum SettingType {
  bool,
  int,
  double,
  string,
}

class Setting<T> {
  final String key;
  final SettingType type;
  final T defaultValue;

  const Setting({
    required this.key,
    required this.type,
    required this.defaultValue,
  });
}
