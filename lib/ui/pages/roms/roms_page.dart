import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_app/models/console.dart';
import 'package:test_app/models/rom_item.dart';
import 'package:test_app/repository/roms_repository.dart';
import 'package:test_app/ui/widgets/console_list.dart';
import 'package:test_app/ui/widgets/flutter_search_bar_custom.dart';
import 'package:test_app/ui/pages/rom_details_dialog/rom_details_dialog.dart';
import 'package:test_app/ui/widgets/unselected_placeholder.dart';
import 'package:animate_do/animate_do.dart';

class RomsPage extends StatefulWidget {
  @override
  RomsPage_State createState() => RomsPage_State();
}

final _romsScaffoldKey = GlobalKey<ScaffoldState>();

class RomsPage_State extends State<RomsPage> {
  Console _selectedConsole = null;
  List<RomItem> _roms = [];
  bool _isLoading = false;
  String _searchQuery = "";
  SearchBar searchBar;
  String getTitle() {
    if (_selectedConsole != null) {
      return "${_selectedConsole.name} roms";
    } else {
      return "Select a console";
    }
  }

  AppBar getDefaultAppbar() {
    return AppBar(
      title: Text(this.getTitle()),
      actions: [searchBar.getSearchAction(context)],
    );
  }

  RomsPage_State() {
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
          return getDefaultAppbar();
        });
  }

  List<RomItem> getFilteredRoms() {
    return _roms
        .where((element) => element.name
            .toLowerCase()
            .contains(this._searchQuery.toLowerCase()))
        .toList();
  }

  void fetchRoms() async {
    setState(() {
      _isLoading = true;
    });
    var roms = await new RomsRepository().fetchRoms(this._selectedConsole);
    setState(() {
      _roms = roms;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext bldContext) {
    return Scaffold(
        key: _romsScaffoldKey,
        appBar: searchBar.build(context),
        body: Column(
          children: [
            ConsoleList(
              selectedConsole: this._selectedConsole,
              onConsoleSelected: (console) {
                setState(() {
                  this._selectedConsole = console;
                });
                setState(() {
                  this._searchQuery = "";
                });
                this.fetchRoms();
              },
            ),
            (this._selectedConsole == null
                ? UnselectedPlaceholder()
                : RomList(
                    isLoading: this._isLoading, roms: this.getFilteredRoms())),
          ],
        ));
  }
}

class RomList extends StatelessWidget {
  bool isLoading = false;
  List<RomItem> roms;
  RomList({this.isLoading, this.roms});
  @override
  Widget build(BuildContext context) {
    return (this.isLoading
        ? Expanded(child: Center(child: CircularProgressIndicator()))
        : Expanded(
            child: Scrollbar(
              isAlwaysShown: kIsWeb,
                          child: ListView.separated(
                  padding: EdgeInsets.all(10),
                  separatorBuilder: (context, index) {
                    return Divider(
                      thickness: 0.2,
                      color: Colors.white,
                    );
                  },
                  itemCount: this.roms.length,
                  itemBuilder: (ctx, index) {
                    return FadeIn(
                        duration: Duration(seconds: 2),
                        child: RomListItem(romItem: this.roms[index]));
                  }),
            ),
          ));
  }
}

class RomListItem extends StatelessWidget {
  final RomItem romItem;
  RomListItem({this.romItem});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => RomDetailsDialog(
                  infoLink: romItem.infoLink,
                ));
      },
      contentPadding: EdgeInsets.all(5),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.network(
          romItem.portrait,
          height: 50,
          width: 50,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        romItem.name,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        romItem.region,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
