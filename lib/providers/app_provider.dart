import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class AppProvider extends ChangeNotifier {
  bool _isAppLoaded = false;
  bool get isAppLoaded => _isAppLoaded;

  setAppLoaded(bool val) {
    _isAppLoaded = val;
    notifyListeners();
  }
}
