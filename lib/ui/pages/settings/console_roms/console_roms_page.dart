import 'package:flutter/material.dart';
import 'package:neonrom3r/models/console.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/repository/roms_repository.dart';
import 'package:neonrom3r/ui/widgets/flutter_search_bar_custom.dart';
import 'package:neonrom3r/ui/widgets/rom_list.dart';

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
  AppBar get defaultAppbar {
    return AppBar(
      title: Text(widget.console.name! + " Roms"),
      actions: [searchBar!.getSearchAction(context)],
    );
  }

  List<RomInfo> get filteredRoms {
    return _roms!
        .where((element) => element.name!
            .toLowerCase()
            .contains(this._searchQuery.toLowerCase()))
        .toList();
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

  _ConsoleRomsPageState() {
    searchBar = new SearchBar(
        setState: setState,
        inBar: true,
        closeOnSubmit: false,
        clearOnSubmit: false,
        onSubmitted: (search) {
          setState(() {
            this._searchQuery = search;
          });
        },
        onCleared: () {
          setState(() {
            this._searchQuery = "";
          });
        },
        onClosed: () {
          setState(() {
            this._searchQuery = "";
          });
        },
        buildDefaultAppBar: (context) {
          return defaultAppbar;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar!.build(context),
      body: RomList(isLoading: this._isLoading, roms: filteredRoms),
    );
  }
}
