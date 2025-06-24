import 'package:flutter/material.dart';
import 'package:spotfy/database/models/music_model.dart';
import 'package:spotfy/pages/widgets/music_grid_item_card.dart'; 


class RecentMusicsSection extends StatelessWidget {
  final List<Musica> musics; // A lista de músicas que eu recebo para exibir.

  const RecentMusicsSection({super.key, required this.musics});

  @override
  Widget build(BuildContext context) {
    // Se a lista de músicas estiver vazia, eu não mostro nada.
    if (musics.isEmpty) {
      return const SizedBox.shrink();
    }

    // Eu organizo o título e a lista de músicas em uma coluna.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinho o conteúdo à esquerda.
      children: [
        // O título da seção.
        const Text(
          'Tocados Recentemente',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8), // Um pequeno espaço abaixo do título.
        // Uso um SizedBox para dar uma altura fixa à minha lista horizontal.
        SizedBox(
          height: 200, // Essa altura acomoda bem meus MusicGridItemCards.
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // Faço a lista rolar na horizontal.
            itemCount: musics.length, // O número de itens é o tamanho da minha lista de músicas.
            itemBuilder: (context, index) {
              final music = musics[index]; // Pego a música atual pelo índice.
              return Padding(
                padding: const EdgeInsets.only(right: 16), // Dou um espaçamento entre cada card.
                child: MusicGridItemCard(music: music), // Uso meu MusicGridItemCard para cada música.
              );
            },
          ),
        ),
      ],
    );
  }
}