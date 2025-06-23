import 'package:flutter/material.dart';
import 'package:spotfy/database/models/artist_model.dart';
import 'music_card_artists.dart'; 

// Widget que representa a seção "Seus Artistas Favoritos" na tela principal ou onde eu precisar
class FavoriteArtistsSection extends StatelessWidget {
  // Recebo a lista de artistas favoritos para exibir dinamicamente
  final List<Artista> artists;

  const FavoriteArtistsSection({super.key, required this.artists});

  @override
  Widget build(BuildContext context) {
    // Se a lista estiver vazia, retorno um SizedBox vazio para não ocupar espaço nem mostrar nada
    if (artists.isEmpty) {
      return const SizedBox.shrink();
    }

    // Caso tenha artistas, mostro a seção com título e lista horizontal
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinho o texto do título à esquerda
      children: [
        // Título da seção com estilo destacado para chamar atenção do usuário
        const Text(
          'Artistas Favoritos',
          style: TextStyle(
            color: Colors.white, 
            fontSize: 20,        
            fontWeight: FontWeight.bold, 
          ),
        ),
        const SizedBox(height: 8), 
        SizedBox(
          height: 180, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal, 
            itemCount: artists.length,        
            itemBuilder: (context, index) {
              final artista = artists[index]; 
              return Padding(
                padding: const EdgeInsets.only(right: 16), 
                child: MusicCard(
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
