// lib/widgets/music_grid_item_card.dart
import 'package:flutter/material.dart';
import 'package:spotfy/database/models/music_model.dart';
import 'package:spotfy/pages/widgets/music_player.dart';
// Importe seu MusicPlayerButton

class MusicGridItemCard extends StatelessWidget {
  final Musica music;

  const MusicGridItemCard({super.key, required this.music});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Ação ao clicar no card: Iniciar a reprodução da música
        if (music.audioPath != null && music.audioPath!.isNotEmpty) {
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Música sem arquivo de áudio para tocar.'),
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Alinha o texto à esquerda
        children: [
          Stack(
            // Usamos Stack para sobrepor o botão de play na imagem
            children: [
              // Área da Capa
              Container(
                width: 140, // Largura do card (ajuste conforme necessário)
                height: 140, // Altura do card (ajuste conforme necessário)
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    8,
                  ), // Bordas arredondadas para o card
                  color: Colors.grey[800], // Cor de fundo padrão
                  image: music.capaBytes != null
                      ? DecorationImage(
                          image: MemoryImage(
                            music.capaBytes!,
                          ), // Usa MemoryImage para bytes
                          fit: BoxFit.cover,
                        )
                      : null, // Sem imagem se capaBytes for nulo
                ),
                child: music.capaBytes == null
                    ? const Icon(
                        Icons.music_note,
                        color: Colors.white54,
                        size: 60,
                      ) // Ícone padrão
                    : null,
              ),
              // Botão de Play no canto inferior direito
              if (music.audioPath != null && music.audioPath!.isNotEmpty)
                Positioned(
                  bottom: 2, // Distância da parte inferior
                  right: 2, // Distância da direita
                  child: MusicPlayerButton(
                    audioPath: music.audioPath!,
                    musicTitle: music.titulo,
                    iconSize: 30, // Tamanho do ícone
                    iconColor: Colors.greenAccent[400]!, // Cor do ícone
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Título da Música
          SizedBox(
            width: 140, // Mesma largura do card
            child: Text(
              music.titulo,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis, // Corta o texto se for muito longo
            ),
          ),
          // Nome do Artista
          SizedBox(
            width: 140, // Mesma largura do card
            child: Text(
              music.artista,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
