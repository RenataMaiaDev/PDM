import 'package:flutter/material.dart';
import 'package:spotfy/database/models/music_model.dart';
import 'package:spotfy/pages/widgets/music_player.dart';

class MusicListTile extends StatelessWidget {
  final Musica musica;

  const MusicListTile({
    super.key,
    required this.musica,
  });

  // Método para formatar a duração (em segundos) para mm:ss
  String _formatDuration(int? durationInSeconds) {
    if (durationInSeconds == null) return '00:00';
    final minutes = (durationInSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationInSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        children: [
          // Container para mostrar a capa da música
          // Se não tiver capa, exibe um ícone padrão
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[800],
              image: musica.capaBytes != null
                  ? DecorationImage(
                      image: MemoryImage(musica.capaBytes!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: musica.capaBytes == null
                ? const Icon(Icons.music_note, color: Colors.white54, size: 30)
                : null,
          ),
          const SizedBox(width: 12),

          // Texto com título da música e nome do artista/álbum
          // Usa Expanded para ocupar espaço disponível
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  musica.titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${musica.artista} • ${musica.album ?? 'Álbum Desconhecido'}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Duração da música formatada para exibição
          Text(
            _formatDuration(musica.duracao),
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          const SizedBox(width: 8),

          // Botão para tocar música (se existir caminho do áudio)
          // Caso contrário, exibe um ícone de mais opções
          musica.audioPath != null && musica.audioPath!.isNotEmpty
              ? MusicPlayerButton(
                  audioPath: musica.audioPath!,
                  musicTitle: musica.titulo,
                )
              : const Icon(Icons.more_vert, color: Colors.white54, size: 20),
        ],
      ),
    );
  }
}
