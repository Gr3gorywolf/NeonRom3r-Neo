class TgdbSearchResult {
  final int id;
  final String title;
  final String platform;
  final String region;
  final String releaseDate;
  final String thumbnail;
  final String detailUrl;

  TgdbSearchResult({
    required this.id,
    required this.title,
    required this.platform,
    required this.region,
    required this.releaseDate,
    required this.thumbnail,
    required this.detailUrl,
  });
}

class TgdbGameDetail {
  final String title;
  final String description;
  final List<String> titleScreens;
  final List<String> screenshots;

  TgdbGameDetail({
    required this.title,
    required this.description,
    required this.titleScreens,
    required this.screenshots,
  });

  factory TgdbGameDetail.fromJson(Map<String, dynamic> json) {
    return TgdbGameDetail(
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      titleScreens: List<String>.from(json['title_screens'] ?? []),
      screenshots: List<String>.from(json['screenshots'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'title_screens': titleScreens,
      'screenshots': screenshots,
    };
  }
}
