import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yamata_launcher/models/rom_info.dart';
import 'package:yamata_launcher/models/rom_library_item.dart';
import 'package:yamata_launcher/models/toolbar_elements.dart';
import 'package:yamata_launcher/providers/download_provider.dart';
import 'package:yamata_launcher/providers/download_sources_provider.dart';
import 'package:yamata_launcher/providers/library_provider.dart';
import 'package:yamata_launcher/ui/widgets/no_downloads_placeholder.dart';
import 'package:yamata_launcher/ui/widgets/rom_list.dart';
import 'package:yamata_launcher/ui/widgets/toolbar.dart';
import 'package:yamata_launcher/services/console_service.dart';
import 'package:yamata_launcher/ui/widgets/view_mode_toggle.dart';
import 'package:yamata_launcher/utils/filter_helpers.dart';

class DownloadsPage extends StatefulWidget {
  @override
  _DownloadsPageState createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  ToolbarValue? filterValues = null;

  @override
  void initState() {
    Future.microtask(() => {compileDownloadedRoms()});
    super.initState();
  }

  bool getIsRomDownloading(RomInfo rom) {
    var downloadProvider = Provider.of<DownloadProvider>(context);
    return downloadProvider.isRomDownloading(rom);
  }

  getFilters(roms) => [
        ToolBarFilterGroup(groupName: "Consoles", filters: [
          ...ConsoleService.getConsoles()
              .where((console) => this
                  ._downloadedRoms
                  .any((library) => library.rom.console == console.slug))
              .map((console) => ToolBarFilterElement(
                  label: console.name ?? "",
                  field: 'rom.console',
                  value: console.slug ?? ""))
              .toList(),
        ]),
        ToolBarFilterGroup(
          groupName: 'Download Status',
          filters: [
            ToolBarFilterElement(
                label: "Ongoing",
                field: 'downloadStatus',
                value: "true",
                matcher: (libraryRom) {
                  return getIsRomDownloading(libraryRom.rom);
                }),
            ToolBarFilterElement(
                label: "Downloaded",
                field: 'isDownloaded',
                value: "true",
                matcher: (libraryRom) {
                  return !getIsRomDownloading(libraryRom.rom);
                }),
          ],
        ),
        ToolBarFilterGroup(
          groupName: 'Availability',
          filters: [
            ToolBarFilterElement(
                label: "Installed",
                field: 'filePath',
                value: "true",
                matcher: (rom) {
                  return rom.filePath != null && rom.filePath!.isNotEmpty;
                }),
            ToolBarFilterElement(
                label: "Never Played",
                field: 'lastPlayedAt',
                value: "true",
                matcher: (rom) {
                  return rom.lastPlayedAt == null;
                }),
            ToolBarFilterElement(
                label: "Favorite", field: 'isFavorite', value: "true"),
          ],
        ),
      ];

  void compileDownloadedRoms() {
    var libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
    var downloadSourcesProvider =
        Provider.of<DownloadSourcesProvider>(context, listen: false);
    var downloads = libraryProvider.getDownloads();
    downloadSourcesProvider
        .compileRomDownloadSources(downloads.map((e) => e.rom).toList());
  }

  List<RomLibraryItem> get _downloadedRoms {
    var provider = LibraryProvider.of(context);
    var romDownloadInfos = DownloadProvider.of(context)
        .activeDownloadInfos
        .map((e) => e.romSlug)
        .toList();
    var downloadingRoms = provider.getBySlugs(romDownloadInfos);
    var downloadedRoms = provider.getDownloads();

    return [
      ...downloadingRoms.toList().reversed,
      ...downloadedRoms
          .where((rom) => !getIsRomDownloading(rom.rom))
          .toList()
          .reversed,
    ];
  }

  bool get hasDownloads {
    return this._downloadedRoms.length > 0;
  }

  List<RomInfo> get filteredDownloads {
    if (filterValues == null) {
      return this._downloadedRoms.map((e) => e.rom).toList();
    }
    return FilterHelpers.handleDynamicFilter<RomLibraryItem>(
            this._downloadedRoms, filterValues!)
        .map((e) => e.rom)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Toolbar(
        onChanged: (values) {
          setState(() {
            filterValues = values;
          });
        },
        initialValues: ToolbarValue(filters: [], search: ''),
        settings: ToolbarSettings(
            title: "Downloads",
            sorts: [
              ToolBarSortByElement(
                  label: 'Name',
                  field: 'name',
                  value: ToolBarSortByType.ascending),
              ToolBarSortByElement(
                  label: 'Added Date',
                  field: 'addedAt',
                  value: ToolBarSortByType.descending),
            ],
            filters: getFilters(_downloadedRoms)),
      ),
      body: (hasDownloads
          ? Column(
              children: [
                Expanded(
                  child: RomList(
                      isLoading: false,
                      showConsole: true,
                      initialViewMode: ViewModeToggleMode.list,
                      roms: filteredDownloads
                          .map(((e) => e))
                          .toList()
                          .take(50)
                          .toList()),
                ),
              ],
            )
          : NoDownloadsPlaceholder()),
    );
  }
}
