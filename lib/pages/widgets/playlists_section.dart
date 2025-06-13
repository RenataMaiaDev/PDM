import 'package:flutter/material.dart';
import '../components/music_card.dart';

// Widget que representa a seção "Suas Playlists"
class PlaylistsSection extends StatelessWidget {
  const PlaylistsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      // Alinha os elementos à esquerda do eixo horizontal
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        const Text(
          'Suas Playlists',
          style: TextStyle(
            color: Colors.white, // Cor do texto
            fontSize: 20,        // Tamanho da fonte
            fontWeight: FontWeight.bold, // Negrito
          ),
        ),
        const SizedBox(height: 8), // Espaço vertical entre o título e a lista
        SizedBox(
          height: 180, // Altura do container que abriga a lista horizontal
          child: ListView(
            scrollDirection: Axis.horizontal, // Lista rolável na horizontal
            children: const [
              // Cartão representando a primeira playlist
              MusicCard(
                imageUrl: 'assets/image/1.jpg', // Caminho da imagem da playlist
                title: 'Playlist 1',            // Nome da playlist
              ),
              // Cartão representando a segunda playlist
              MusicCard(
                imageUrl: 'assets/image/1.jpg',
                title: 'Playlist 2',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
