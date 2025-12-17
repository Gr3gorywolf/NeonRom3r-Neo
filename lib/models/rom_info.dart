class RomInfo {
  String? title;
  String? portrait;
  String? logo;
  String? titleImage;
  List<String>? gameplayCovers;
  String? size;
  String? region;
  String? console;
  String? downloadLink;

  RomInfo(
      {this.title,
      this.portrait,
      this.size,
      this.region,
      this.console,
      this.downloadLink});

  RomInfo.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    portrait = json['portrait'];
    logo = json['logo'];
    titleImage = json['titleImage'];
    gameplayCovers = json['gameplayCovers'] != null
        ? List<String>.from(json['gameplayCovers'])
        : null;
    size = json['size'];
    region = json['region'];
    console = json['console'];
    downloadLink = json['downloadLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['portrait'] = this.portrait;
    data['size'] = this.size;
    data['region'] = this.region;
    data['logo'] = this.logo;
    data['titleImage'] = this.titleImage;
    data['gameplayCovers'] = this.gameplayCovers;
    data['console'] = this.console;
    data['downloadLink'] = this.downloadLink;
    return data;
  }
}
