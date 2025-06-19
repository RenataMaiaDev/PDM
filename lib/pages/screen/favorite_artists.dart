import 'package:flutter/material.dart';
import 'package:spotfy/database/models/artist_model.dart';
import '../widgets/music_card_artists.dart';

class FavoriteArtistsSection extends StatelessWidget {
  // Recebo a lista de artistas favoritos para exibir
  final List<Artista> artists;

  const FavoriteArtistsSection({super.key, required this.artists});

  @override
  Widget build(BuildContext context) {
    // Se a lista estiver vazia, não exibo nada (tamanho zero)
    if (artists.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção de artistas favoritos
        const Text(
          'Artistas Favoritos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8), // Espaço abaixo do título
        SizedBox(
          height: 180, // Altura fixa para o carrossel horizontal
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // Lista horizontal para scroll
            itemCount: artists.length, // Quantidade de artistas a exibir
            itemBuilder: (context, index) {
              final artista = artists[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16), // Espaço entre os cards
                child: MusicCard( // Widget customizado para mostrar artista (nome atualizado)
                  artist: artista,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
