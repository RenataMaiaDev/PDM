import 'package:flutter/material.dart';
import 'package:spotfy/database/models/playlist_model.dart';
import 'package:spotfy/database/repositories/playlist_repository.dart';
import 'package:spotfy/pages/widgets/playlist_card.dart';

/// Esta é a tela onde eu mostro minhas playlists.
/// Aqui eu posso ver todas elas e gerenciá-las.
class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

/// O estado da tela de playlists, onde eu cuido do carregamento e da exibição.
class _PlaylistsScreenState extends State<PlaylistsScreen> {
  // O repositório que eu uso para pegar os dados das playlists no banco.
  final PlaylistRepository _playlistRepo = PlaylistRepository();

  // A lista onde eu guardo as playlists que carrego.
  List<Playlist> _playlists = [];

  // Uma flag para eu saber se os dados estão sendo carregados.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Assim que a tela aparece, eu já começo a carregar minhas playlists.
    _loadPlaylists();
  }

  /// Minha função para carregar as playlists do banco de dados.
  /// Eu atualizo a tela para mostrar o progresso e os resultados.
  Future<void> _loadPlaylists() async {
    setState(() {
      _isLoading = true; // Ativo o indicador de carregamento.
    });
    try {
      // Pego todas as playlists usando meu repositório.
      final playlists = await _playlistRepo.getAllPlaylists();
      if (mounted) {
        // Verifico se a tela ainda está ativa antes de atualizar.
        setState(() {
          _playlists = playlists; // Atualizo a lista de playlists.
          _isLoading = false; // Desativo o indicador.
        });
      }
    } catch (e) {
      // Se der erro ao carregar, eu mostro uma mensagem.
      debugPrint('PlaylistsScreen - Erro ao carregar playlists: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar minhas playlists.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto, combinando com o tema.
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0, // Sem sombra na barra superior.
        title: const Text(
          'Playlists', // O título da minha tela.
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body:
          _isLoading // Se estiver carregando, eu mostro um círculo de progresso.
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF05D853)),
            )
          : RefreshIndicator(
              // Permite que eu puxe para baixo para recarregar.
              onRefresh:
                  _loadPlaylists, // Chama minha função de carregar playlists.
              color: const Color(0xFF05D853),
              child:
                  _playlists
                      .isEmpty // Se não houver playlists, eu mostro uma mensagem.
                  ? Center(
                      child: SingleChildScrollView(
                        // Para permitir o pull-to-refresh mesmo sem itens.
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: const Text(
                          'Você não possui playlists. Crie uma nova!',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Padding(
                      // Adiciono um espaçamento em volta da grade de playlists.
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        // Eu uso uma grade para exibir as playlists.
                        physics:
                            const AlwaysScrollableScrollPhysics(), // Para que o pull-to-refresh funcione.
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Duas playlists por linha.
                              crossAxisSpacing: 16.0, // Espaçamento horizontal.
                              mainAxisSpacing: 16.0, // Espaçamento vertical.
                              childAspectRatio:
                                  0.8, // Proporção para o tamanho dos cards.
                            ),
                        itemCount: _playlists
                            .length, // O número de playlists que tenho.
                        itemBuilder: (context, index) {
                          final playlist = _playlists[index];
                          return PlaylistCard(
                            // Para cada playlist, eu uso meu widget PlaylistCard.
                            playlist: playlist,
                            onDelete:
                                _loadPlaylists, // Se uma playlist for deletada, eu recarrego a lista.
                          );
                        },
                      ),
                    ),
            ),
    );
  }
}
