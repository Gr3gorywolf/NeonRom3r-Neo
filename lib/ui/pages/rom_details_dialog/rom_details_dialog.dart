import 'package:flutter/material.dart';
import 'package:test_app/models/rom_info.dart';
import 'package:test_app/models/rom_item.dart';
import 'package:test_app/repository/roms_repository.dart';
import 'package:test_app/ui/pages/rom_details_dialog/widgets/rom_details_dialog_content.dart';

class RomDetailsDialog extends StatefulWidget {
  static show(BuildContext context, RomItem romItem) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => RomDetailsDialog(
              infoLink: romItem.infoLink,
            ));
  }

  String infoLink;
  RomDetailsDialog({@required this.infoLink});
  @override
  _RomDetailsDialogState createState() => _RomDetailsDialogState();
}

class _RomDetailsDialogState extends State<RomDetailsDialog> {
  bool _isLoading = false;
  RomInfo _rom;
  @override
  void initState() {
    super.initState();
    fetchInfo();
  }

  fetchInfo() async {
    setState(() {
      _isLoading = true;
    });
    var rom = await RomsRepository().fetchRomDetails(widget.infoLink);
    setState(() {
      _rom = rom;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : RomDetailsContent(
                rom: this._rom,
              ),
      ),
    );
  }
}
