import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:test_app/models/rom_info.dart';
import 'package:animate_do/animate_do.dart';
import 'package:test_app/providers/download_provider.dart';
import 'package:test_app/ui/widgets/download_spinner.dart';
import 'package:test_app/utils/alerts_helpers.dart';
import 'package:test_app/utils/downloads_helper.dart';
import 'package:test_app/utils/roms_helper.dart';
import 'package:toast/toast.dart';

class RomDetailsContent extends StatefulWidget {
  final RomInfo rom;
  RomDetailsContent({this.rom});

  @override
  _RomDetailsContentState createState() => _RomDetailsContentState();
}

class _RomDetailsContentState extends State<RomDetailsContent> {
  handleDownload() {
    DownloadsHelper().downloadRom(this.widget.rom);
    Navigator.pop(context);
    Toast.show("Download started...", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  handlePlay() {
    var downloaded = DownloadsHelper().getDownloadedRoms();
    var rom = downloaded.firstWhere(
        (element) => element.downloadLink == widget.rom.downloadLink);
    RomsHelper.openDownloadedRom(rom);
  }

  @override
  Widget build(BuildContext context) {
    var _provider = DownloadProvider.of(context);
    var _isDownloading = _provider.isRomDownloading(widget.rom);
    var _isReadyToPlay = _provider.isRomReadyToPlay(widget.rom);
    Widget buildDownloadButton() {
      if (_isDownloading) {
        var _downloadInfo = _provider.getDownloadInfo(widget.rom);
        var _percent = _downloadInfo.downloadPercent.toDouble();
        return RomDetailsAction(
            leading: DownloadSpinner(_percent),
            title: "Downloading...\n Tap to cancel",
            animationDelay: Duration(milliseconds: 50),
            onTap: () {
              AlertsHelpers.showAlert(context, "Warning",
                  "You are sure you want to cancel this download?",
                  acceptTitle: "Yes", callback: () {
                FlutterDownloader.cancel(taskId: _downloadInfo.downloadId);

              }, cancelable: true);
            });
      }
      if (_isReadyToPlay) {
        return RomDetailsAction(
            leading: Icon(Icons.play_arrow_sharp, color: Colors.green),
            title: "Play",
            animationDelay: Duration(milliseconds: 50),
            onTap: handlePlay);
      } else {
        return RomDetailsAction(
            leading: Icon(Icons.file_download, color: Colors.green),
            title: "Download",
            animationDelay: Duration(milliseconds: 50),
            onTap: handleDownload);
      }
    }

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
                buildDownloadButton(),
                RomDetailsAction(
                  leading: Icon(Icons.share, color: Colors.green),
                  title: "Share",
                  animationDelay: Duration(milliseconds: 20),
                  onTap: null,
                ),
                RomDetailsAction(
                  leading: Icon(Icons.close, color: Colors.green),
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
  Widget leading;
  Duration animationDelay;
  RomDetailsAction({this.onTap, this.leading, this.animationDelay, this.title});
  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: animationDelay,
      child: ListTile(
        onTap: () {
          this.onTap();
        },
        leading: this.leading,
        title: Text(
          this.title,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}
