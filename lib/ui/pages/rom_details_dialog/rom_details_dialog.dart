import 'package:flutter/material.dart';
import 'package:test_app/models/rom_info.dart';
import 'package:test_app/repository/roms_repository.dart';
import 'package:test_app/ui/pages/rom_details_dialog/widgets/rom_details_dialog_content.dart';

class RomDetailsDialog extends StatefulWidget {
  static show(BuildContext context, RomInfo romItem) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => RomDetailsDialog(
              rom: romItem,
            ));
  }

  RomInfo rom;
  RomDetailsDialog({@required this.rom});
  @override
  _RomDetailsDialogState createState() => _RomDetailsDialogState();
}

class _RomDetailsDialogState extends State<RomDetailsDialog> {
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : RomDetailsContent(
                rom: widget.rom,
              ),
      ),
    );
  }
}
