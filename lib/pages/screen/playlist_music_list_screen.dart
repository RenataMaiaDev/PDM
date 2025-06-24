import 'package:flutter/material.dart';
import 'package:spotfy/database/models/playlist_model.dart';
import 'package:spotfy/database/models/music_model.dart';
import 'package:spotfy/database/repositories/playlist_repository.dart';
import 'package:spotfy/pages/widgets/music_list_title.dart';

// Tela que exibe a lista de músicas de uma playlist específica.
// Recebe um objeto [playlist] como argumento para carregar suas músicas.
class PlaylistMusicListScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistMusicListScreen({super.key, required this.playlist});

  @override
  State<PlaylistMusicListScreen> createState() => _PlaylistMusicListScreenState();
}

// Estado da [PlaylistMusicListScreen], responsável por carregar e exibir as músicas.
class _PlaylistMusicListScreenState extends State<PlaylistMusicListScreen> {
  // Repositório para interagir com os dados das playlists no banco.
  final PlaylistRepository _playlistRepo = PlaylistRepository();
  
  // Lista que armazenará as músicas da playlist.
  List<Musica> _playlistMusics = [];
  
  // Flag para controlar o estado de carregamento dos dados.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inicia o carregamento das músicas da playlist ao iniciar a tela.
    _loadPlaylistMusics();
  }

  // Carrega as músicas de uma playlist específica do banco de dados.
  // Atualiza o estado da tela após o carregamento ou em caso de erro.
  Future<void> _loadPlaylistMusics() async {
    setState(() {
      _isLoading = true; // Ativa o indicador de carregamento.
    });
    try {
      // Verifica se o ID da playlist é válido antes de tentar carregar.
      if (widget.playlist.id != null) {
        // Busca as músicas associadas à playlist usando o repositório.
        final musics = await _playlistRepo.getMusicasFromPlaylist(widget.playlist.id!);
        if (mounted) { // Garante que o widget ainda está ativo na árvore de widgets.
          setState(() {
            _playlistMusics = musics; // Atualiza a lista de músicas.
            _isLoading = false; // Desativa o indicador de carregamento.
          });
        }
      } else {
        // Caso o ID da playlist seja nulo, imprime um debug e exibe um erro.
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
      // Em caso de qualquer erro no carregamento, imprime e exibe uma SnackBar.
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
      backgroundColor: Colors.black, // Define o fundo da tela.
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0, // Remove a sombra da AppBar.
        title: Text(
          widget.playlist.nome, // O título da AppBar é o nome da playlist.
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Define a cor do ícone de voltar.
      ),
      body: _isLoading // Condicionalmente exibe o indicador de carregamento ou o conteúdo.
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF05D853)), // Indicador de progresso.
            )
          : RefreshIndicator( // Permite ao usuário puxar para baixo para recarregar a lista.
              onRefresh: _loadPlaylistMusics,
              color: const Color(0xFF05D853),
              child: _playlistMusics.isEmpty // Se a lista estiver vazia, exibe uma mensagem.
                  ? Center(
                      child: SingleChildScrollView( // Usado para permitir o pull-to-refresh mesmo com lista vazia.
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: const Text(
                          'Nenhuma música nesta playlist. Adicione algumas!',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder( // Constrói a lista de músicas.
                      physics: const AlwaysScrollableScrollPhysics(), // Permite rolagem mesmo com poucos itens para o RefreshIndicator.
                      itemCount: _playlistMusics.length, // Número de itens na lista.
                      itemBuilder: (context, index) {
                        final musica = _playlistMusics[index];
                        return MusicListTile(musica: musica); // Cada item da lista usa o widget MusicListTile.
                      },
                    ),
            ),
    );
  }
}