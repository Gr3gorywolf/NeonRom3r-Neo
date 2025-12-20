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
}
