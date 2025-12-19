import 'dart:io';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/providers/download_provider.dart';
import 'package:neonrom3r/ui/pages/rom_details_dialog/rom_details_dialog.dart';
import 'package:neonrom3r/ui/widgets/rom_action_button.dart';
import 'package:neonrom3r/ui/widgets/rom_list_item.dart';
import 'package:neonrom3r/ui/widgets/rom_thumbnail.dart';
import 'package:neonrom3r/ui/widgets/view_mode_toggle.dart';
import 'package:neonrom3r/utils/consoles_helper.dart';
import 'package:neonrom3r/utils/constants.dart';
import 'package:neonrom3r/utils/files_system_helper.dart';

class RomList extends StatefulWidget {
  bool? isLoading = false;
  List<RomInfo>? roms;
  bool showConsole;
  RomList({this.isLoading, this.roms, this.showConsole = false});

  @override
  State<RomList> createState() => _RomListState();
}

class _RomListState extends State<RomList> {
  ViewModeToggleMode _viewMode = ViewModeToggleMode.list;

  @override
  Widget build(BuildContext context) {
    var gridAxisCount =
        max(1, (MediaQuery.of(context).size.width / 220).floor());
    if (widget.isLoading == true) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ViewModeToggle(
                  value: _viewMode,
                  onChanged: (value) {
                    setState(() => _viewMode = value);
                  },
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
          if (_viewMode == ViewModeToggleMode.list)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final rom = widget.roms![index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RomListItem(
                      romItem: rom,
                      showConsole: widget.showConsole,
                      itemType: RomListItemType.listItem,
                    ),
                  );
                },
                childCount: widget.roms!.length,
              ),
            ),
          if (_viewMode == ViewModeToggleMode.grid)
            SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final rom = widget.roms![index];
                    return RomListItem(
                        romItem: rom,
                        showConsole: widget.showConsole,
                        itemType: RomListItemType.card);
                  },
                  childCount: widget.roms!.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridAxisCount,
                  mainAxisExtent: 410,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                )),
        ],
      ),
    );
  }
}
