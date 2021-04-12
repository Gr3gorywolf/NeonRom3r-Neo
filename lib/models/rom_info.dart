class RomInfo {
  String name;
  String portrait;
  String size;
  String region;
  String console;
  String downloadLink;

  RomInfo(
      {this.name,
      this.portrait,
      this.size,
      this.region,
      this.console,
      this.downloadLink});

  RomInfo.fromJson(Map<String, dynamic> json) {
    name = json['Name'];
    portrait = json['Portrait'];
    size = json['Size'];
    region = json['Region'];
    console = json['Console'];
    downloadLink = json['DownloadLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Name'] = this.name;
    data['Portrait'] = this.portrait;
    data['Size'] = this.size;
    data['Region'] = this.region;
    data['Console'] = this.console;
    data['DownloadLink'] = this.downloadLink;
    return data;
  }
}