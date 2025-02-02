import 'package:flutter/material.dart';
import 'package:pokemondex/pokemondetail/views/pokemondetail_view.dart';
import 'package:pokemondex/pokemonlist/models/pokemonlist_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonList extends StatefulWidget {
  const PokemonList({Key? key}) : super(key: key);

  @override
  State<PokemonList> createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  late Future<List<PokemonListItem>> _pokemonListFuture;

  @override
  void initState() {
    super.initState();
    _pokemonListFuture = fetchPokemonList();
  }

  Future<List<PokemonListItem>> fetchPokemonList() async {
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=1000'));

    if (response.statusCode == 200) {
      final data = PokemonListResponse.fromJson(jsonDecode(response.body));
      return data.results;
    } else {
      throw Exception('Failed to load Pokémon data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PokemonListItem>>(
      future: _pokemonListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No Pokémon found'));
        }

        final pokemonList = snapshot.data!;

        return ListView.builder(
          itemCount: pokemonList.length,
          itemBuilder: (context, index) {
            final pokemon = pokemonList[index];
            final pokemonId = int.parse(pokemon.url.split("/").where((segment) => segment.isNotEmpty).last);
            final imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png";

            return ListTile(
              leading: Image.network(
                imageUrl,
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
              ),
              title: Text(pokemon.name),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemondetailView(
                    pokemonList: pokemonList,
                    currentIndex: index,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
