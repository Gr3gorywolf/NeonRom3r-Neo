import 'package:neonrom3r/models/rom_download.dart';

class DownloadInfo {
  RomDownload download;
  int downloadPercent;
  String downloadId;
  bool get isCompleted {
    return downloadPercent == 100;
  }
  DownloadInfo({this.download, this.downloadPercent, this.downloadId});
}
