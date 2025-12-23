import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:neonrom3r/models/console.dart';
import 'package:neonrom3r/models/emulator.dart';
import 'package:neonrom3r/models/rom_library_item.dart';
import 'package:neonrom3r/models/toolbar_elements.dart';
import 'package:neonrom3r/providers/download_sources_provider.dart';
import 'package:neonrom3r/providers/library_provider.dart';
import 'package:neonrom3r/repository/emulators_repository.dart';
import 'package:neonrom3r/services/console_service.dart';
import 'package:neonrom3r/ui/widgets/console_card.dart';
import 'package:neonrom3r/ui/widgets/rom_list.dart';
import 'package:neonrom3r/ui/widgets/toolbar.dart';
import 'package:neonrom3r/utils/filter_helpers.dart';
import 'package:provider/provider.dart';

var _initialToolbarValues = ToolbarValue(
    filters: [],
    search: '',
    sortBy: ToolBarSortByElement(
        label: 'Added Date',
        field: 'addedAt',
        value: ToolBarSortByType.descending));

class LibraryPage extends StatefulWidget {
  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  ToolbarValue? filterValues = _initialToolbarValues;

  initState() {
    Future.microtask(() {
      var libraryProvider =
          Provider.of<LibraryProvider>(context, listen: false);
      Provider.of<DownloadSourcesProvider>(context, listen: false)
          .compileRomSources(
              libraryProvider.libraryItems.map((e) => e.rom).toList());
    }).then((value) => null);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var libraryProvider = LibraryProvider.of(context);
    var roms = libraryProvider.libraryItems;
    var getFilteredRoms = () {
      if (filterValues == null) return roms.map((e) => e.rom).toList();
      return FilterHelpers.handleDynamicFilter<RomLibraryItem>(
              roms, filterValues!)
          .map((e) => e.rom)
          .toList();
    };

    return Scaffold(
      appBar: Toolbar(
        onChanged: (values) {
          setState(() {
            filterValues = values;
          });
        },
        settings: ToolbarSettings(
          title: "Library",
          filters: [
            ToolBarFilterGroup(
              groupName: 'Consoles',
              filters: roms.map((e) => e.rom.console).toSet().map((console) {
                return ToolBarFilterElement(
                    label:
                        ConsoleService.getConsoleFromName(console)?.name ?? "",
                    field: 'rom.console.slug',
                    value: console);
              }).toList(),
            ),
            ToolBarFilterGroup(
              groupName: 'Availability',
              filters: [
                ToolBarFilterElement(
                    label: "Favorite", field: 'isFavorite', value: "true"),
              ],
            ),
          ],
          sorts: [
            ToolBarSortByElement(
                label: 'Name',
                field: 'rom.name',
                value: ToolBarSortByType.ascending),
            ToolBarSortByElement(
                label: 'Added Date',
                field: 'addedAt',
                value: ToolBarSortByType.ascending),
            ToolBarSortByElement(
                label: 'Played time',
                field: 'playTimeMins',
                value: ToolBarSortByType.ascending),
          ],
        ),
        initialValues: _initialToolbarValues,
      ),
      body: RomList(
        showConsole: true,
        roms: getFilteredRoms(),
      ),
    );
  }
}
