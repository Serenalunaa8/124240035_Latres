class Episode {
  final int id;
  final String name;
  final String airDate;
  final String episode;
  final List<String> characters;

  Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.episode,
    required this.characters,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    final rawCharacters = json['characters'] as List? ?? [];
    return Episode(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      airDate: json['air_date'] ?? '',
      episode: json['episode'] ?? '',
      characters: rawCharacters.map((c) => c.toString()).toList(),
    );
  }
}
