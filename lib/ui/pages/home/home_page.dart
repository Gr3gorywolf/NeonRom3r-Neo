import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:neonrom3r/models/console.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/repository/roms_repository.dart';
import 'package:neonrom3r/ui/pages/console_roms/console_roms_page.dart';
import 'package:neonrom3r/ui/widgets/console_list.dart';
import 'package:neonrom3r/ui/widgets/console_card.dart';
import 'package:neonrom3r/ui/widgets/flutter_search_bar_custom.dart';
import 'package:neonrom3r/ui/pages/rom_details_dialog/rom_details_dialog.dart';
import 'package:neonrom3r/ui/widgets/rom_list.dart';
import 'package:neonrom3r/ui/widgets/unselected_placeholder.dart';
import 'package:animate_do/animate_do.dart';
import 'package:neonrom3r/utils/consoles_helper.dart';

class HomePage extends StatefulWidget {
  @override
  HomePage_State createState() => HomePage_State();
}

class HomePage_State extends State<HomePage> {
  List<Console> _consoles = ConsolesHelper.getConsoles();

  @override
  Widget build(BuildContext bldContext) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Home"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Consoles",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: ConsoleList(
                  consoles: _consoles,
                  onConsoleSelected: (Console console) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ConsoleRomsPage(console)));
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
