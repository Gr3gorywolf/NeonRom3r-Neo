import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:yamata_launcher/ui/widgets/rom_list_item.dart';
import 'package:yamata_launcher/ui/widgets/view_mode_toggle.dart';
import 'package:provider/provider.dart';

class AppProvider extends ChangeNotifier {
  static AppProvider of(BuildContext ctx) {
    return Provider.of<AppProvider>(ctx);
  }

  bool _isAppLoaded = false;
  bool get isAppLoaded => _isAppLoaded;
  ViewModeToggleMode consoleRomsItemType = ViewModeToggleMode.grid;
  setAppLoaded(bool val) {
    _isAppLoaded = val;
    if (Platform.isAndroid) {
      consoleRomsItemType = ViewModeToggleMode.list;
    }
    notifyListeners();
  }

  setConsoleRomsItemType(ViewModeToggleMode type) {
    consoleRomsItemType = type;
    notifyListeners();
  }
}
