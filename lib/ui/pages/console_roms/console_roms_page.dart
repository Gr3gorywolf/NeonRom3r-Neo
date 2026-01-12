import 'package:flutter/material.dart';
import 'package:yamata_launcher/models/console.dart';
import 'package:yamata_launcher/models/rom_info.dart';
import 'package:yamata_launcher/models/toolbar_elements.dart';
import 'package:yamata_launcher/providers/app_provider.dart';
import 'package:yamata_launcher/providers/download_provider.dart';
import 'package:yamata_launcher/providers/download_sources_provider.dart';
import 'package:yamata_launcher/providers/library_provider.dart';
import 'package:yamata_launcher/repository/roms_repository.dart';
import 'package:yamata_launcher/ui/widgets/rom_list.dart';
import 'package:yamata_launcher/ui/widgets/toolbar.dart';
import 'package:provider/provider.dart';

import '../../../utils/filter_helpers.dart';

class ConsoleRomsPage extends StatefulWidget {
  Console console;
  List<RomInfo>? infos;
  ConsoleRomsPage(this.console, {this.infos});
  @override
  _ConsoleRomsPageState createState() => _ConsoleRomsPageState();
}

class _ConsoleRomsPageState extends State<ConsoleRomsPage> {
  String _searchQuery = "";
  List<RomInfo>? _roms = [];
  bool _isLoading = false;
  ToolbarValue? filterValues = null;

  List<RomInfo> get filteredRoms {
    if (_roms == null) return [];
    if (filterValues == null) return _roms!;
    return FilterHelpers.handleDynamicFilter<RomInfo>(_roms!, filterValues!);
  }

  @override
  void initState() {

    super.initState();
    if (widget.infos == null) {
      fetchRoms();
    } else {
      _roms = widget.infos;
    }
  }

  void fetchRoms() async {
    setState(() {
      _isLoading = true;
    });
    var roms = await new RomsRepository().fetchRoms(widget.console);
    var downloadSourcesProvider =
        Provider.of<DownloadSourcesProvider>(context, listen: false);
    downloadSourcesProvider.compileRomDownloadSources(roms);
    setState(() {
      _roms = roms;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var appProvider = Provider.of<AppProvider>(context);
    var downloadSourcesProvider = Provider.of<DownloadSourcesProvider>(context);
    var libraryProvider = Provider.of<LibraryProvider>(context);
    return Scaffold(
      appBar: Toolbar(
        onChanged: (values) {
          setState(() {
            filterValues = values;
          });
        },
        initialValues: ToolbarValue(
            filters: [],
            search: '',
            sortBy: ToolBarSortByElement(
                label: 'Name',
                field: 'name',
                value: ToolBarSortByType.ascending)),
        settings: ToolbarSettings(title: widget.console.name, sorts: [
          ToolBarSortByElement(
              label: 'Name', field: 'name', value: ToolBarSortByType.ascending),
          ToolBarSortByElement(
              label: 'Release Date',
              field: 'releaseDate',
              value: ToolBarSortByType.ascending),
        ], filters: [
          ToolBarFilterGroup(
            groupName: "Availability",
            filters: [
              ToolBarFilterElement(
                  label: "Downloaded",
                  field: "isDownloaded",
                  value: "",
                  matcher: (romInfo) {
                    var libItem = libraryProvider.getLibraryItem(romInfo.slug);
                    return libItem != null && libItem.downloadedAt != null;
                  }),
              ToolBarFilterElement(
                label: "Not Downloaded",
                field: "isNotDownloaded",
                value: "",
                matcher: (romInfo) {
                  var libItem = libraryProvider.getLibraryItem(romInfo.slug);
                  return libItem == null || libItem.downloadedAt == null;
                },
              ),
              ToolBarFilterElement(
                label: "Download Available",
                field: "isDownloadAvailable",
                value: "",
                matcher: (romInfo) {
                  return downloadSourcesProvider
                          .isRomCompilingDownloadSources(romInfo.slug) ||
                      downloadSourcesProvider
                          .getRomSources(romInfo.slug)
                          .isNotEmpty;
                },
              ),
            ],
          )
        ]),
      ),
      body: RomList(
        isLoading: this._isLoading,
        roms: filteredRoms,
        initialViewMode: appProvider.consoleRomsItemType,
        onViewModeChanged: (mode) {
          appProvider.setConsoleRomsItemType(mode);
        },
      ),
    );
  }
}
