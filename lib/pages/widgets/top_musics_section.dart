// lib/widgets/top_musics_section.dart
import 'package:flutter/material.dart';
import 'package:spotfy/database/models/music_model.dart';
import 'package:spotfy/pages/widgets/music_grid_item_card.dart';

class TopMusicsSection extends StatelessWidget {
  final List<Musica> musics;

  const TopMusicsSection({super.key, required this.musics});

  @override
  Widget build(BuildContext context) {
    if (musics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Músicas Mais Ouvidas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox( // Usamos SizedBox para dar uma altura fixa à ListView horizontal
          height: 200, // Altura que acomoda o MusicGridItemCard (140px imagem + 8px espaço + 2x ~15px texto)
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // Define a rolagem como horizontal
            itemCount: musics.length,
            itemBuilder: (context, index) {
              final music = musics[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16), // Espaçamento entre os cards
                child: MusicGridItemCard(music: music), // <<< Usando o MusicGridItemCard aqui
              );
            },
          ),
        ),
      ],
    );
  }
}