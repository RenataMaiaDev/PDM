// lib/screens/playlist_music_list_screen.dart
import 'package:flutter/material.dart';
import 'package:spotfy/database/models/playlist_model.dart';
import 'package:spotfy/database/models/music_model.dart';
import 'package:spotfy/database/repositories/playlist_repository.dart';
import 'package:spotfy/pages/widgets/music_list_title.dart';

class PlaylistMusicListScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistMusicListScreen({super.key, required this.playlist});

  @override
  State<PlaylistMusicListScreen> createState() => _PlaylistMusicListScreenState();
}

class _PlaylistMusicListScreenState extends State<PlaylistMusicListScreen> {
  final PlaylistRepository _playlistRepo = PlaylistRepository();
  List<Musica> _playlistMusics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylistMusics();
  }

  Future<void> _loadPlaylistMusics() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (widget.playlist.id != null) {
        final musics = await _playlistRepo.getMusicasFromPlaylist(widget.playlist.id!);
        if (mounted) {
          setState(() {
            _playlistMusics = musics;
            _isLoading = false;
          });
        }
      } else {
        debugPrint('PlaylistMusicListScreen - ID da playlist é nulo. Não é possível carregar músicas.');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro: ID da playlist não encontrado.')),
          );
        }
      }
    } catch (e) {
      debugPrint('PlaylistMusicListScreen - Erro ao carregar músicas da playlist: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar músicas desta playlist.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.playlist.nome, // Título da AppBar será o nome da playlist
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Cor da seta de voltar
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF05D853)),
            )
          : RefreshIndicator( // Permite puxar para baixo para recarregar as músicas
              onRefresh: _loadPlaylistMusics,
              color: const Color(0xFF05D853),
              child: _playlistMusics.isEmpty
                  ? Center(
                      child: SingleChildScrollView( // Permite o RefreshIndicator funcionar
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Text(
                          'Nenhuma música nesta playlist. Adicione algumas!',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _playlistMusics.length,
                      itemBuilder: (context, index) {
                        final musica = _playlistMusics[index];
                        return MusicListTile(musica: musica); // Reutiliza o MusicListTile
                      },
                    ),
            ),
    );
  }
}