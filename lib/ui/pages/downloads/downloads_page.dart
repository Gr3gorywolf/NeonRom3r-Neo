import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/models/toolbar_elements.dart';
import 'package:neonrom3r/providers/download_provider.dart';
import 'package:neonrom3r/providers/library_provider.dart';
import 'package:neonrom3r/ui/widgets/console_list.dart';
import 'package:neonrom3r/ui/widgets/no_downloads_placeholder.dart';
import 'package:neonrom3r/ui/pages/home/home_page.dart';
import 'package:neonrom3r/ui/widgets/rom_list.dart';
import 'package:neonrom3r/ui/widgets/toolbar.dart';
import 'package:neonrom3r/services/console_service.dart';
import 'package:neonrom3r/services/download_service.dart';
import 'package:neonrom3r/ui/widgets/view_mode_toggle.dart';
import 'package:neonrom3r/utils/filter_helpers.dart';

class DownloadsPage extends StatefulWidget {
  @override
  _DownloadsPageState createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  ToolbarValue? filterValues = null;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  List<RomInfo> get _downloadedRoms {
    var provider = LibraryProvider.of(context);
    var romDownloadInfos = DownloadProvider.of(context)
        .activeDownloadInfos
        .map((e) => e.romSlug)
        .toList();
    var downloadingRoms = provider.getBySlugs(romDownloadInfos);
    var downloadedRoms = provider.getDownloads();

    return [
      ...downloadingRoms.map((e) => e.rom).toList().reversed,
      ...downloadedRoms.map((e) => e.rom).toList().reversed,
    ];
  }

  bool get hasDownloads {
    return this._downloadedRoms.length > 0;
  }

  List<RomInfo> get filteredDownloads {
    if (filterValues == null) {
      return this._downloadedRoms;
    }
    return FilterHelpers.handleDynamicFilter<RomInfo>(
        this._downloadedRoms, filterValues!);
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
        settings: ToolbarSettings(title: "Downloads", sorts: [
          ToolBarSortByElement(
              label: 'Name', field: 'name', value: ToolBarSortByType.ascending),
        ], filters: [
          ToolBarFilterGroup(groupName: "Consoles", filters: [
            ...ConsoleService.getConsoles()
                .map((console) => ToolBarFilterElement(
                    label: console.name ?? "",
                    field: 'console',
                    value: console.slug ?? ""))
                .toList(),
          ]),
        ]),
      ),
      body: (hasDownloads
          ? Column(
              children: [
                Expanded(
                  child: RomList(
                      isLoading: false,
                      showConsole: true,
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
