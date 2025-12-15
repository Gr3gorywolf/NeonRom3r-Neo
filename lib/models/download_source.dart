import 'download_source_rom.dart';

class DownloadSource {
  String title;
  int romsCount;
  String lastUpdated;

  DownloadSource({this.title, this.romsCount, this.lastUpdated});

  DownloadSource.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    romsCount = json['roms_count'];
    lastUpdated = json['last_updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['roms_count'] = this.romsCount;
    data['last_updated'] = this.lastUpdated;
    return data;
  }
}

class DownloadSourceWithDownloads {
  DownloadSource sourceInfo;
  List<DownloadSourceRom> downloads;

  DownloadSourceWithDownloads({this.sourceInfo, this.downloads});

  DownloadSourceWithDownloads.fromJson(Map<String, dynamic> json) {
    sourceInfo = json['sourceInfo'] != null
        ? new DownloadSource.fromJson(json['sourceInfo'])
        : null;
    if (json['downloads'] != null) {
      downloads = [];
      json['downloads'].forEach((v) {
        downloads.add(new DownloadSourceRom.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.sourceInfo != null) {
      data['sourceInfo'] = this.sourceInfo.toJson();
    }
    if (this.downloads != null) {
      data['downloads'] = this.downloads.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
