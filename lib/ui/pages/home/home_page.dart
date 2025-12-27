import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yamata_launcher/models/console.dart';
import 'package:yamata_launcher/models/rom_info.dart';
import 'package:yamata_launcher/models/toolbar_elements.dart';
import 'package:yamata_launcher/repository/roms_repository.dart';
import 'package:yamata_launcher/ui/pages/console_roms/console_roms_page.dart';
import 'package:yamata_launcher/ui/widgets/console_list.dart';
import 'package:yamata_launcher/ui/widgets/console_card.dart';
import 'package:yamata_launcher/ui/pages/rom_details_dialog/rom_details_dialog.dart';
import 'package:yamata_launcher/ui/widgets/rom_list.dart';
import 'package:yamata_launcher/ui/widgets/toolbar.dart';
import 'package:yamata_launcher/ui/widgets/unselected_placeholder.dart';
import 'package:animate_do/animate_do.dart';
import 'package:yamata_launcher/services/console_service.dart';
import 'package:yamata_launcher/utils/filter_helpers.dart';

class HomePage extends StatefulWidget {
  @override
  HomePage_State createState() => HomePage_State();
}

class HomePage_State extends State<HomePage> {
  List<Console> _consoles = ConsoleService.getConsoles(unique: true)
    ..sort((a, b) => a.name?.compareTo(b.name ?? "") ?? 0);
  ToolbarValue? filterValues = null;

  get filteredConsoles {
    if (filterValues == null) return _consoles;
    var newConsoles =
        FilterHelpers.handleDynamicFilter<Console>(_consoles, filterValues!);
    return newConsoles;
  }

  @override
  Widget build(BuildContext bldContext) {
    return Scaffold(
        appBar: Toolbar(
          settings: ToolbarSettings(
              title: "Yamata Launcher", searchHint: "Search Consoles"),
          onChanged: (val) => {
            setState(() {
              filterValues = val;
            })
          },
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
                  consoles: filteredConsoles,
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
