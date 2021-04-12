import 'package:flutter/material.dart';
import 'package:test_app/models/rom_info.dart';
import 'package:test_app/models/rom_item.dart';
import 'package:test_app/services/roms_api_client.dart';
import 'package:test_app/ui/components/rom_details.dart/rom_details_content.dart';

class RomDetails extends StatefulWidget {
  static openModal(BuildContext context, RomItem romItem) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => RomDetails(
              infoLink: romItem.infoLink,
            ));
  }

  String infoLink;
  RomDetails({@required this.infoLink});
  @override
  _RomDetailsState createState() => _RomDetailsState();
}

class _RomDetailsState extends State<RomDetails> {
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
    var rom = await RomsApiClient().getRomDetails(widget.infoLink);
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
