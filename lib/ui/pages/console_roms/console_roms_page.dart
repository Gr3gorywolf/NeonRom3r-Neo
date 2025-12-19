import 'package:flutter/material.dart';
import 'package:neonrom3r/models/console.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/models/toolbar_elements.dart';
import 'package:neonrom3r/providers/app_provider.dart';
import 'package:neonrom3r/providers/download_provider.dart';
import 'package:neonrom3r/repository/roms_repository.dart';
import 'package:neonrom3r/ui/widgets/flutter_search_bar_custom.dart';
import 'package:neonrom3r/ui/widgets/rom_list.dart';
import 'package:neonrom3r/ui/widgets/toolbar.dart';
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
  SearchBar? searchBar;
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
    // TODO: implement initState
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
    setState(() {
      _roms = roms;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var appProvider = Provider.of<AppProvider>(context);

    final TextEditingController _controller = TextEditingController();
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
        settings: ToolbarSettings(
          title: widget.console.name,
          sorts: [
            ToolBarSortByElement(
                label: 'Name',
                field: 'name',
                value: ToolBarSortByType.ascending),
            ToolBarSortByElement(
                label: 'Release Date',
                field: 'releaseDate',
                value: ToolBarSortByType.ascending),
          ],
        ),
      ),
      body: RomList(
        isLoading: this._isLoading,
        roms: filteredRoms,
        viewMode: appProvider.consoleRomsItemType,
        onViewModeChanged: (mode) {
          appProvider.setConsoleRomsItemType(mode);
        },
      ),
    );
  }
}
