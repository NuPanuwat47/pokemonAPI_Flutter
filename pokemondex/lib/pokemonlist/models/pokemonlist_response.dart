class PokemonListResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<PokemonListItem> results;

  PokemonListResponse({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    return PokemonListResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: List<PokemonListItem>.from(
          json['results'].map((x) => PokemonListItem.fromJson(x))),
    );
  }
}

class PokemonListItem {
  final String name;
  final String png;
  final String url;

  PokemonListItem({
    required this.name,
    required this.png,
    required this.url,
  });

  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    return PokemonListItem(
      name: json['name'],
      png:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${_extractId(json['url'])}.png',
      url: json['url'],
    );
  }

  get length => null;
  static String _extractId(String url) {
    return url.split('/').where((segment) => segment.isNotEmpty).last;
  }
}
