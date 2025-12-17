import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/utils/roms_helper.dart';

class RomDownload {
  String? filePath;
  String? name;
  String? portrait;
  String? downloadLink;
  String? console;
  String? size;
  static RomDownload fromRomInfo(RomInfo romInfo, String? downloadPath) {
    return RomDownload(
        console: romInfo.console,
        name: romInfo.name,
        portrait: romInfo.portrait,
        filePath: downloadPath);
  }

  RomInfo toRomInfo() {
    return RomInfo(
      console: this.console ?? "",
      slug: RomsHelper.normalizeRomTitle(this.name ?? ""),
      name: this.name ?? "",
      portrait: this.portrait,
    );
  }

  RomDownload(
      {this.filePath,
      this.name,
      this.portrait,
      this.downloadLink,
      this.console,
      this.size});

  bool isRomInfoEqual(RomInfo romInfo) {
    return this.name == romInfo.name && this.console == romInfo.console;
  }

  RomDownload.fromJson(Map<String, dynamic> json) {
    filePath = json['FilePath'];
    name = json['Name'];
    portrait = json['Portrait'];
    downloadLink = json['DownloadLink'];
    console = json['Console'];
    size = json['Size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FilePath'] = this.filePath;
    data['Name'] = this.name;
    data['Portrait'] = this.portrait;
    data['DownloadLink'] = this.downloadLink;
    data['Console'] = this.console;
    data['Size'] = this.size;
    return data;
  }
}
