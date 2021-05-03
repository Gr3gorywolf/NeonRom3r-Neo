import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class AppProvider extends ChangeNotifier {
  static AppProvider of(BuildContext ctx) {
    return Provider.of<AppProvider>(ctx);
  }
  bool _isAppLoaded = false;
  bool get isAppLoaded => _isAppLoaded;
  setAppLoaded(bool val) {
    _isAppLoaded = val;
    notifyListeners();
  }
}
