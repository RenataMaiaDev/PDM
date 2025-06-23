// lib/widgets/playlist_card.dart
import 'package:flutter/material.dart';
import 'package:spotfy/database/models/playlist_model.dart';
import 'package:spotfy/database/repositories/playlist_repository.dart';
import 'package:spotfy/pages/screen/playlist_music_list_screen.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onDelete; // Callback para notificar a tela superior sobre a exclusão

  const PlaylistCard({
    super.key,
    required this.playlist,
    this.onDelete,
  });

  // Função para confirmar e deletar a playlist
  Future<void> _confirmAndDeletePlaylist(BuildContext context) async {
    if (playlist.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: ID da playlist não encontrado para exclusão.')),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('Excluir Playlist', style: TextStyle(color: Colors.white)),
          content: Text(
            'Tem certeza que deseja excluir a playlist "${playlist.nome}"?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final playlistRepo = PlaylistRepository();
        await playlistRepo.deletePlaylist(playlist.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playlist "${playlist.nome}" excluída com sucesso!')),
        );
        onDelete?.call(); // Chama o callback para recarregar a lista na PlaylistsScreen
      } catch (e) {
        debugPrint('PlaylistCard - Erro ao deletar playlist: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir playlist. Tente novamente.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // <<< ENVOLVE O CARD COM GestureDetector
      onTap: () {
        // Navega para a tela de lista de músicas da playlist
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistMusicListScreen(playlist: playlist),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[800],
                  image: playlist.capaBytes != null
                      ? DecorationImage(
                          image: MemoryImage(playlist.capaBytes!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: playlist.capaBytes == null
                    ? const Icon(Icons.playlist_play, color: Colors.white54, size: 60)
                    : null,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white70, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.all(4),
                  ),
                  onPressed: () => _confirmAndDeletePlaylist(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            playlist.nome,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            playlist.descricao ?? '',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}