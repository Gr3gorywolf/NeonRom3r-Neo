import 'package:neonrom3r/models/contracts/json_serializable.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/utils/filter_helpers.dart';
import 'package:neonrom3r/services/rom_service.dart';

class RomDownload implements JsonSerializable {
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
      slug: RomService.normalizeRomTitle(this.name ?? ""),
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
    filePath = json['filePath'];
    name = json['name'];
    portrait = json['portrait'];
    downloadLink = json['downloadLink'];
    console = json['console'];
    size = json['size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['filePath'] = this.filePath;
    data['name'] = this.name;
    data['portrait'] = this.portrait;
    data['downloadLink'] = this.downloadLink;
    data['console'] = this.console;
    data['size'] = this.size;
    return data;
  }
}
