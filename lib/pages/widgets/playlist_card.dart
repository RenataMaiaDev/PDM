import 'package:flutter/material.dart';
import 'package:spotfy/database/models/playlist_model.dart';
import 'package:spotfy/database/repositories/playlist_repository.dart';
import 'package:spotfy/pages/screen/playlist_music_list_screen.dart';

// Meu card para exibir uma playlist.
class PlaylistCard extends StatelessWidget {
  final Playlist playlist; // A playlist a ser exibida.
  final VoidCallback? onDelete; // Callback para quando a playlist for deletada.

  const PlaylistCard({
    super.key,
    required this.playlist,
    this.onDelete,
  });

  // Confirma e deleta a playlist.
  Future<void> _confirmAndDeletePlaylist(BuildContext context) async {
    if (playlist.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: ID da playlist não encontrado.')),
      );
      return;
    }

    // Mostro um AlertDialog para confirmar.
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

    // Se confirmado, tento deletar.
    if (confirm == true) {
      try {
        final playlistRepo = PlaylistRepository();
        await playlistRepo.deletePlaylist(playlist.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playlist "${playlist.nome}" excluída!')),
        );
        onDelete?.call(); // Notifico a tela superior.
      } catch (e) {
        debugPrint('PlaylistCard - Erro ao deletar: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir. Tente novamente.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Torno o card clicável.
      onTap: () {
        // Ao clicar, navego para a tela de músicas da playlist.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistMusicListScreen(playlist: playlist),
          ),
        );
      },
      child: Column( // Organizo o conteúdo em uma coluna.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack( // Para sobrepor a imagem e o botão de deletar.
            children: [
              Container( // Área da capa da playlist.
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[800],
                  // Exibo a capa ou um ícone padrão.
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
              Positioned( // Botão de deletar no canto superior direito.
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white70, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54, // Fundo semitransparente.
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    minimumSize: Size.zero, // Botão compacto.
                    padding: const EdgeInsets.all(4),
                  ),
                  onPressed: () => _confirmAndDeletePlaylist(context), // Chamo a função de exclusão.
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text( // Nome da playlist.
            playlist.nome,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text( // Descrição da playlist.
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