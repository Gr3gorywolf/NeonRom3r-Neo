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
import 'package:neonrom3r/services/console_service.dart';
import 'package:neonrom3r/constants/app_constants.dart';
import 'package:neonrom3r/services/files_system_service.dart';

class RomList extends StatefulWidget {
  bool? isLoading = false;
  List<RomInfo>? roms;
  bool showConsole;
  ViewModeToggleMode viewMode;
  Function(ViewModeToggleMode)? onViewModeChanged;
  RomList(
      {this.isLoading,
      this.roms,
      this.showConsole = false,
      this.viewMode = ViewModeToggleMode.list,
      this.onViewModeChanged});

  @override
  State<RomList> createState() => _RomListState();
}

class _RomListState extends State<RomList> {
  @override
  Widget build(BuildContext context) {
    var gridAxisCount =
        max(1, (MediaQuery.of(context).size.width / 250).floor());
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
                  value: widget.viewMode,
                  onChanged: (value) {
                    setState(() => widget.viewMode = value);
                    if (widget.onViewModeChanged != null) {
                      widget.onViewModeChanged!(value);
                    }
                  },
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
          if (widget.viewMode == ViewModeToggleMode.list)
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
          if (widget.viewMode == ViewModeToggleMode.grid)
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
