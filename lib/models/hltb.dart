class HltbEntry {
  final String id;
  final String name;
  final String description;
  final List<String> platforms;
  final String imageUrl;
  final int gameplayMain;
  final int gameplayMainExtra;
  final int gameplayCompletionist;
  final double similarity;
  final String searchTerm;

  HltbEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.platforms,
    required this.imageUrl,
    required this.gameplayMain,
    required this.gameplayMainExtra,
    required this.gameplayCompletionist,
    required this.similarity,
    required this.searchTerm,
  });
}
