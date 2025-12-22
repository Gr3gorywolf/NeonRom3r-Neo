import 'package:neonrom3r/models/rom_library_item.dart';

class DownloadInfo {
  String romSlug;
  int? downloadPercent;
  String? downloadId;
  String? downloadInfo;
  bool get isCompleted {
    return downloadPercent == 100;
  }

  DownloadInfo(
      {required this.romSlug,
      this.downloadPercent,
      this.downloadId,
      this.downloadInfo});
}
