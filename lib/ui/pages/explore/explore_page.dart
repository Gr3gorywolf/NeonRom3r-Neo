import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

class ExplorePage extends StatefulWidget {
  @override
  ExplorePage_State createState() => ExplorePage_State();
}

class ExplorePage_State extends State<ExplorePage> {
  List<Console> _consoles = ConsoleService.getConsoles(unique: true)
    ..sort((a, b) => a.name?.compareTo(b.name ?? "") ?? 0);
  ToolbarValue? filterValues = null;

  var textController = TextEditingController();

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
          settings: ToolbarSettings(title: "Explore", disableSearch: true),
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: 'Search for roms',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (value) {
                        textController.clear();
                        context.push("/explore/search-results", extra: value);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Platforms",
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
                    context.push("/explore/console-roms", extra: console);
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
