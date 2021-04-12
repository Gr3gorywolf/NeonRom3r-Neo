import 'package:flutter/cupertino.dart';
import 'package:test_app/ui/screens/roms.dart';
import 'package:test_app/ui/screens/consoles.dart';
 class AppRoutes {
  Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
    '/roms': (BuildContext ctx) => RomsPage(),
    '/consoles':(BuildContext ctx) => Consoles()
  };
}
