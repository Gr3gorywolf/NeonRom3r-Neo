import 'package:test_app/models/rom_info.dart';

class RomDownload {
  String filePath;
  String name;
  String portrait;
  String downloadLink;
  String console;
  String region;
  String size;
  static RomDownload fromRomInfo(RomInfo romInfo, String downloadPath) {
    return RomDownload(
        console: romInfo.console,
        downloadLink: romInfo.downloadLink,
        name: romInfo.name,
        portrait: romInfo.portrait,
        region: romInfo.region,
        size: romInfo.size,
        filePath: downloadPath);
  }

  RomInfo toRomInfo() {
    return RomInfo(
        console: this.console,
        downloadLink: this.downloadLink,
        name: this.name,
        portrait: this.portrait,
        region: this.region,
        size: this.size);
  }

  RomDownload(
      {this.filePath,
      this.name,
      this.portrait,
      this.downloadLink,
      this.console,
      this.region,
      this.size});

  RomDownload.fromJson(Map<String, dynamic> json) {
    filePath = json['FilePath'];
    name = json['Name'];
    portrait = json['Portrait'];
    downloadLink = json['DownloadLink'];
    console = json['Console'];
    region = json['Region'];
    size = json['Size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FilePath'] = this.filePath;
    data['Name'] = this.name;
    data['Portrait'] = this.portrait;
    data['DownloadLink'] = this.downloadLink;
    data['Console'] = this.console;
    data['Region'] = this.region;
    data['Size'] = this.size;
    return data;
  }
}
