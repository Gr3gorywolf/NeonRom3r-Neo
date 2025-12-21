import 'package:neonrom3r/models/contracts/json_serializable.dart';

class HltbEntry implements JsonSerializable {
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

  factory HltbEntry.fromJson(Map<String, dynamic> json) {
    return HltbEntry(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? "",
      platforms: List<String>.from(json['platforms'] ?? []),
      imageUrl: json['image_url'] ?? "",
      gameplayMain: json['gameplay_main'] ?? 0,
      gameplayMainExtra: json['gameplay_main_extra'] ?? 0,
      gameplayCompletionist: json['gameplay_completionist'] ?? 0,
      similarity: (json['similarity'] ?? 0).toDouble(),
      searchTerm: json['search_term'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'platforms': platforms,
      'image_url': imageUrl,
      'gameplay_main': gameplayMain,
      'gameplay_main_extra': gameplayMainExtra,
      'gameplay_completionist': gameplayCompletionist,
      'similarity': similarity,
      'search_term': searchTerm,
    };
  }
}
