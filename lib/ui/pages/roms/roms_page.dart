import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:neonrom3r/models/console.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/repository/roms_repository.dart';
import 'package:neonrom3r/ui/pages/console_roms/console_roms_page.dart';
import 'package:neonrom3r/ui/widgets/console_list.dart';
import 'package:neonrom3r/ui/widgets/console_tile.dart';
import 'package:neonrom3r/ui/widgets/flutter_search_bar_custom.dart';
import 'package:neonrom3r/ui/pages/rom_details_dialog/rom_details_dialog.dart';
import 'package:neonrom3r/ui/widgets/rom_list.dart';
import 'package:neonrom3r/ui/widgets/unselected_placeholder.dart';
import 'package:animate_do/animate_do.dart';
import 'package:neonrom3r/utils/consoles_helper.dart';

class RomsPage extends StatefulWidget {
  @override
  RomsPage_State createState() => RomsPage_State();
}

final _romsScaffoldKey = GlobalKey<ScaffoldState>();

class RomsPage_State extends State<RomsPage> {
  List<Console> _consoles = ConsolesHelper.getConsoles();

  @override
  Widget build(BuildContext bldContext) {
    return Scaffold(
        key: _romsScaffoldKey,
        appBar: AppBar(
          title: Text("Roms"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: List.generate(_consoles.length, (index) {
              var _console = _consoles[index];
              return InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ConsoleRomsPage(_console)));
                  },
                  child: ConsoleTile(_console));
            }),
          ),
        ));
  }
}
