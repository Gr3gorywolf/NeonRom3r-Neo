import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:neonrom3r/models/rom_download.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/models/toolbar_elements.dart';
import 'package:neonrom3r/providers/download_provider.dart';
import 'package:neonrom3r/ui/widgets/console_list.dart';
import 'package:neonrom3r/ui/widgets/no_downloads_placeholder.dart';
import 'package:neonrom3r/ui/pages/home/home_page.dart';
import 'package:neonrom3r/ui/widgets/rom_list.dart';
import 'package:neonrom3r/ui/widgets/toolbar.dart';
import 'package:neonrom3r/utils/consoles_helper.dart';
import 'package:neonrom3r/utils/downloads_helper.dart';
import 'package:neonrom3r/utils/filter_helpers.dart';

class DownloadsPage extends StatefulWidget {
  @override
  _DownloadsPageState createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  List<RomDownload> _downloadedRoms = [];
  ToolbarValue? filterValues = null;
  int _currentSelection = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool get hasDownloads {
    return this._downloadedRoms.length > 0;
  }

  List<RomDownload> get filteredDownloads {
    if (filterValues == null) return _downloadedRoms;
    return FilterHelpers.handleDynamicFilter<RomDownload>(
        _downloadedRoms, filterValues!,
        nameField: 'name');
  }

  @override
  Widget build(BuildContext context) {
    var provider = DownloadProvider.of(context);
    _downloadedRoms = provider.downloadsRegistry.toList();

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
        settings: ToolbarSettings(title: "Downloads", sorts: [
          ToolBarSortByElement(
              label: 'Name', field: 'name', value: ToolBarSortByType.ascending),
        ], filters: [
          ToolBarFilterGroups(groupName: "Consoles", filters: [
            ...ConsolesHelper.getConsoles()
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
                          .map(((e) => e.toRomInfo()))
                          .toList()
                          .reversed
                          .take(50)
                          .toList()),
                ),
              ],
            )
          : NoDownloadsPlaceholder()),
    );
  }
}
