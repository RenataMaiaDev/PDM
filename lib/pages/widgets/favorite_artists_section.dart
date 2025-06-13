import 'package:flutter/material.dart';
import '../components/music_card_artists.dart';

// Widget que representa a seção "Seus Artistas Favoritos"
class FavoriteArtistsSection extends StatelessWidget {
  const FavoriteArtistsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      // Alinha os elementos à esquerda (início do eixo horizontal)
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        const Text(
          'Seus Artistas Favoritos',
          style: TextStyle(
            color: Colors.white, // Cor do texto
            fontSize: 20,         // Tamanho da fonte
            fontWeight: FontWeight.bold, // Negrito
          ),
        ),
        const SizedBox(height: 8), // Espaço vertical entre o título e a lista
        SizedBox(
          height: 180, // Altura da lista horizontal de artistas
          child: ListView(
            scrollDirection: Axis.horizontal, // Define o eixo de rolagem como horizontal
            children: const [
              // Cartão representando o primeiro artista
              MusicCard(
                imageUrl: 'assets/image/1.jpg', // Caminho da imagem
                title: 'Artista 1',              // Nome do artista
              ),
              // Cartão representando o segundo artista
              MusicCard(
                imageUrl: 'assets/image/2.jpg',
                title: 'Artista 2',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
