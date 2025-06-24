import 'package:flutter/material.dart';
import 'package:spotfy/database/models/music_model.dart';
import 'package:spotfy/pages/widgets/music_grid_item_card.dart';

class TopMusicsSection extends StatelessWidget {
  final List<Musica> musics; // A lista de músicas mais ouvidas que eu recebo.

  const TopMusicsSection({super.key, required this.musics});

  @override
  Widget build(BuildContext context) {
    // Se por acaso a lista de músicas estiver vazia, eu simplesmente não mostro nada.
    if (musics.isEmpty) {
      return const SizedBox.shrink();
    }

    // Eu organizo tudo numa coluna, com o título em cima e a lista abaixo.
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Alinho o conteúdo à esquerda.
      children: [
        // Meu título para essa seção.
        const Text(
          'Músicas Mais Ouvidas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 8,
        ), // Um pequeno espaço para separar o título da lista.
        // Uso um SizedBox para garantir que minha lista horizontal tenha uma altura definida.
        SizedBox(
          height:
              200, // Essa altura acomoda perfeitamente os meus `MusicGridItemCard`s.
          child: ListView.builder(
            scrollDirection:
                Axis.horizontal, // Faço a lista rolar na horizontal.
            itemCount: musics
                .length, // O número de itens na lista é o mesmo da minha lista de músicas.
            itemBuilder: (context, index) {
              final music = musics[index]; // Pego cada música da lista.
              return Padding(
                padding: const EdgeInsets.only(
                  right: 16,
                ), // Adiciono um espaçamento entre cada card de música.
                child: MusicGridItemCard(
                  music: music,
                ), // E aqui eu uso o meu `MusicGridItemCard` para exibir cada uma.
              );
            },
          ),
        ),
      ],
    );
  }
}
