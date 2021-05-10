import 'package:animate_do/animate_do.dart';
import 'package:any_widget_marquee/any_widget_marquee.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:test_app/models/rom_info.dart';
import 'package:test_app/providers/download_provider.dart';
import 'package:test_app/ui/pages/rom_details_dialog/widgets/rom_details_action_button.dart';
import 'package:test_app/ui/widgets/download_spinner.dart';
import 'package:test_app/utils/alerts_helpers.dart';
import 'package:test_app/utils/downloads_helper.dart';
import 'package:test_app/utils/roms_helper.dart';
import 'package:toast/toast.dart';

class RomDetailsBottomSheet extends StatefulWidget {
  final RomInfo rom;
  RomDetailsBottomSheet(this.rom);
  @override
  _RomDetailsBottomSheetState createState() => _RomDetailsBottomSheetState();
}

class _RomDetailsBottomSheetState extends State<RomDetailsBottomSheet> {
  double _iconsSize = 30;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //Rom details row
            Row(
              children: [
                Image.network(
                  widget.rom.portrait,
                  height: 94,
                  width: 94,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.rom.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.rom.size,
                          style: TextStyle(color: Colors.green[700]),
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.rom.region,
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ],
                      mainAxisSize: MainAxisSize.min),
                )
              ],
            ),

            //Rom actions row
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RomDetailsActionButton(widget.rom),
                SizedBox(
                  width: 12,
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.share,
                    size: _iconsSize,
                  ),
                  color: Colors.green,
                ),
                /*FadeInLeft(
                  delay: Duration(milliseconds: 200),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_drop_down_circle_outlined,
                      size: _iconsSize,
                    ),
                    color: Colors.green,
                  ),
                )*/
              ],
            )
          ],
        ),
      ),
    );
  }
}
