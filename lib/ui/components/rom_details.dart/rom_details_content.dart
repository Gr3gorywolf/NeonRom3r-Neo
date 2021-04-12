import 'dart:io';
import 'package:flutter/material.dart';
import 'package:test_app/models/rom_info.dart';
import 'package:animate_do/animate_do.dart';
import 'package:test_app/utils/downloads_helper.dart';
import 'package:toast/toast.dart';

class RomDetailsContent extends StatefulWidget {
  final RomInfo rom;
  RomDetailsContent({this.rom});

  @override
  _RomDetailsContentState createState() => _RomDetailsContentState();
}

class _RomDetailsContentState extends State<RomDetailsContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: EdgeInsets.fromLTRB(0, 90, 0, 0),
      child: Column(
        children: [
          FadeInUp(
              delay: Duration(milliseconds: 70),
              child: Column(
                children: [
                  Center(
                    child: Image.network(
                      widget.rom.portrait,
                      height: 180,
                      width: 180,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.rom.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.rom.region,
                    style: TextStyle(color: Colors.green[700]),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.rom.size,
                    style: TextStyle(color: Colors.green[700]),
                  ),
                  SizedBox(height: 60),
                ],
              )),
          Container(
            padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
            child: Column(
              children: [
                RomDetailsAction(
                    icon: Icons.file_download,
                    title: "Download",
                    animationDelay: Duration(milliseconds: 50),
                    onTap: () {
                      DownloadsHelper().downloadRom(this.widget.rom);
                      Navigator.pop(context);
                      Toast.show("Download started...", context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    }),
                RomDetailsAction(
                  icon: Icons.share,
                  title: "Share",
                  animationDelay: Duration(milliseconds: 20),
                  onTap: null,
                ),
                RomDetailsAction(
                  icon: Icons.close,
                  title: "Close",
                  animationDelay: Duration(milliseconds: 0),
                  onTap: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RomDetailsAction extends StatelessWidget {
  Function onTap;
  IconData icon;
  String title;
  Duration animationDelay;
  RomDetailsAction({this.onTap, this.icon, this.animationDelay, this.title});
  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: animationDelay,
      child: ListTile(
        onTap: () {
          this.onTap();
        },
        leading: Icon(
          this.icon,
          color: Colors.green,
        ),
        title: Text(
          this.title,
          style: TextStyle(
              color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}
