import 'package:yamata_launcher/models/rom_info.dart';
import 'package:yamata_launcher/models/rom_library_item.dart';

class DownloadInfo {
  String romSlug;
  int? downloadPercent;
  String? downloadId;
  String? downloadInfo;
  bool isExtracting;
  RomInfo? romInfo;
  bool isExtraContent;
  bool get isCompleted {
    return downloadPercent == 100;
  }

  DownloadInfo(
      {required this.romSlug,
      this.downloadPercent,
      this.downloadId,
      this.romInfo,
      this.isExtraContent = false,
      this.isExtracting = false,
      this.downloadInfo});
}
