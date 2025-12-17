import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:neonrom3r/models/console.dart';
import 'package:neonrom3r/models/emulator.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/ui/widgets/emulator_list_item.dart';

class ConsoleEmulatorsPage extends StatefulWidget {
  List<Emulator> emulators;
  Console console;
  ConsoleEmulatorsPage(this.console, this.emulators);
  @override
  _ConsoleEmulatorsPageState createState() => _ConsoleEmulatorsPageState();
}

class _ConsoleEmulatorsPageState extends State<ConsoleEmulatorsPage> {
  String _searchQuery = "";
  SearchBar? searchBar;
  bool _isLoading = false;
  AppBar get defaultAppbar {
    return AppBar(
      title: Text(widget.console.name! + " Emulators"),
      actions: [searchBar!.getSearchAction(context)],
    );
  }

  List<Emulator> get filteredEmulators {
    return widget.emulators
        .where((element) => element.name!
            .toLowerCase()
            .contains(this._searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  _ConsoleEmulatorsPageState() {
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
      body: ListView.separated(
          padding: EdgeInsets.all(10),
          separatorBuilder: (context, index) {
            return Divider(
              thickness: 0.2,
              color: Colors.white,
            );
          },
          itemCount: filteredEmulators.length,
          itemBuilder: (ctx, index) {
            return FadeIn(
                duration: Duration(seconds: 2),
                child: EmulatorListItem(filteredEmulators[index]));
          }),
    );
  }
}
