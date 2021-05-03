import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_app/models/rom_info.dart';
import 'package:test_app/ui/pages/rom_details_dialog/rom_details_dialog.dart';
import 'package:test_app/ui/widgets/download_indicator.dart';

class RomList extends StatelessWidget {
  bool isLoading = false;
  List<RomInfo> roms;
  RomList({this.isLoading, this.roms});
  @override
  Widget build(BuildContext context) {
    return (this.isLoading
        ? Center(child: CircularProgressIndicator())
        : Scrollbar(
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
        ));
  }
}

class RomListItem extends StatelessWidget {
  final RomInfo romItem;
  RomListItem({this.romItem});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => RomDetailsDialog(
                  rom: romItem,
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
      trailing: DownloadIndicator(romItem),
    );
  }
}
