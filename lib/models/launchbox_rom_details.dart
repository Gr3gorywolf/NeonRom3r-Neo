import 'package:yamata_launcher/models/contracts/json_serializable.dart';

class LaunchboxRomDetails implements JsonSerializable {
  String? description;
  String? maxPlayers;
  bool? cooperative;
  String? esrb;
  List<String>? genres;
  String? video;
  List<String>? screenshots;

  LaunchboxRomDetails(
      {this.description,
      this.maxPlayers,
      this.cooperative,
      this.esrb,
      this.genres,
      this.video,
      this.screenshots});

  LaunchboxRomDetails.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    maxPlayers = json['maxPlayers'];
    cooperative = json['cooperative'];
    esrb = json['esrb'];
    genres = json['genres'].cast<String>();
    video = json['video'];
    screenshots = json['screenshots'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['maxPlayers'] = this.maxPlayers;
    data['cooperative'] = this.cooperative;
    data['esrb'] = this.esrb;
    data['genres'] = this.genres;
    data['video'] = this.video;
    data['screenshots'] = this.screenshots;
    return data;
  }
}
