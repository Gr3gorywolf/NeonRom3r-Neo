class RomItem {
  String name;
  String portrait;
  String infoLink;
  String region;

  RomItem({this.name, this.portrait, this.infoLink, this.region});

  RomItem.fromJson(Map<String, dynamic> json) {
    name = json['Name'];
    portrait = json['Portrait'];
    infoLink = json['InfoLink'];
    region = json['Region'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Name'] = this.name;
    data['Portrait'] = this.portrait;
    data['InfoLink'] = this.infoLink;
    data['Region'] = this.region;
    return data;
  }
}