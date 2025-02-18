class Artist {
  final String name;
  final String origin;
  final String year;
  final String? edition;
  final String? style;
  final String? website;
  final String? spotify;

  Artist({
    required this.name,
    required this.origin,
    required this.year,
    this.edition,
    this.style,
    this.website,
    this.spotify,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      name: json['artiste'] ?? '',
      origin: json['origine_pays1'] ?? '',
      year: json['annee'] ?? '',
      edition: json['edition'],
      style: json['style_1'],
      website: json['website'],
      spotify: json['spotify'],
    );
  }
}
