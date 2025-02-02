import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pokemondex/pokemonlist/models/pokemonlist_response.dart';

class PokemondetailView extends StatefulWidget {
  final List<PokemonListItem> pokemonList;
  final int currentIndex;

  const PokemondetailView({
    Key? key,
    required this.pokemonList,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<PokemondetailView> createState() => _PokemondetailViewState();
}

class _PokemondetailViewState extends State<PokemondetailView> {
  Map<String, dynamic>? pokemonData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData(widget.pokemonList[widget.currentIndex].name);
  }

  Future<void> loadData(String pokemonName) async {
    final apiUrl = 'https://pokeapi.co/api/v2/pokemon/$pokemonName';
    try {
      setState(() => isLoading = true);
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          pokemonData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print('Failed to load Pokémon data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _navigateToDetail(int newIndex) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PokemondetailView(
          pokemonList: widget.pokemonList,
          currentIndex: newIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pokemonList[widget.currentIndex].name),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pokemonData == null
              ? const Center(child: Text('No data available'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.network(
                          pokemonData!['sprites']['front_default'] ??
                              "https://via.placeholder.com/150",
                          width: 150,
                          height: 150,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Name: ${pokemonData!['name'].toUpperCase()}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Type: ${_getTypes()}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Base Stats:',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Center(child: const SizedBox(height: 10)),
                      ..._buildStats(),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: widget.currentIndex > 0
                                ? () =>
                                    _navigateToDetail(widget.currentIndex - 1)
                                : null,
                            child: const Text('Back'),
                          ),
                          ElevatedButton(
                            onPressed: widget.currentIndex <
                                    widget.pokemonList.length - 1
                                ? () =>
                                    _navigateToDetail(widget.currentIndex + 1)
                                : null,
                            child: const Text('Next'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
    );
  }

  String _getTypes() {
    List types = pokemonData!['types'];
    return types.map((type) => type['type']['name']).join(', ');
  }

  List<Widget> _buildStats() {
    List stats = pokemonData!['stats'];
    return stats
        .map((stat) => Center(
              child: Text(
                '${stat['stat']['name']}: ${stat['base_stat']}',
                style: const TextStyle(fontSize: 14),
              ),
            ))
        .toList();
  }
}
