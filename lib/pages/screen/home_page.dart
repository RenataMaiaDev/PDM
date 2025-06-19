import 'package:flutter/material.dart';
import 'package:spotfy/database/models/music_model.dart';
import 'package:spotfy/database/models/artist_model.dart';
import 'package:spotfy/database/models/playlist_model.dart';
import 'package:spotfy/database/repositories/music_repository.dart';
import 'package:spotfy/database/repositories/artist_repository.dart';
import 'package:spotfy/database/repositories/playlist_repository.dart';
import 'package:spotfy/pages/screen/user.dart';

import '../widgets/favorite_artists_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Instâncias dos repositórios para acessar os dados do banco
  final MusicRepository _musicRepo = MusicRepository();
  final ArtistRepository _artistRepo = ArtistRepository();
  final PlaylistRepository _playlistRepo = PlaylistRepository();

  // Variáveis que vão armazenar os dados carregados para exibir na home
  List<Musica> _recentMusics = [];
  List<Musica> _topMusics = [];
  List<Playlist> _playlists = [];
  List<Artista> _favoriteArtists = [];
  List<Musica> _recommendedStations = [];

  bool _isLoading = true; // Controla se está carregando dados para mostrar feedback visual

  @override
  void initState() {
    super.initState();
    // Carrego os dados da home assim que o widget é criado
    _loadHomePageData();
  }

  Future<void> _loadHomePageData() async {
    setState(() {
      _isLoading = true; // Ativo indicador de carregamento
    });
    try {
      // Busco as músicas recentes, mais tocadas, artistas favoritos, playlists e estações recomendadas
      final recent = await _musicRepo.getRecentMusicas(limit: 5);
      final top = await _musicRepo.getTopMusicas(limit: 6);
      final artists = await _artistRepo.getFavoriteArtists(limit: 6);
      final playlists = await _playlistRepo.getAllPlaylists();
      final allMusics = await _musicRepo.getAllMusicas();
      final recommended = allMusics.take(6).toList();

      if (mounted) { // Verifico se o widget ainda está na tela antes de atualizar o estado
        setState(() {
          _recentMusics = recent;
          _topMusics = top;
          _favoriteArtists = artists;
          _playlists = playlists;
          _recommendedStations = recommended;
          _isLoading = false; // Desativo o loading pois os dados já foram carregados
        });
      }
    } catch (e) {
      // Em caso de erro, mostro no debug e exibo uma mensagem para o usuário
      debugPrint('HomePage - Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false; // Desativo o loading para evitar spinner eterno
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading home data. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto para combinar com tema escuro
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Spotify', // Título da app bar
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              // Enquanto carrega dados, exibe um indicador visual
              child: CircularProgressIndicator(color: Color(0xFF05D853)),
            )
          : RefreshIndicator(
              // Permite dar pull-to-refresh para recarregar os dados da home
              onRefresh: _loadHomePageData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // RecentSection(musicas: _recentMusics),
                    // const SizedBox(height: 24),
                    // TopMusicSection(musicas: _topMusics),
                    // const SizedBox(height: 24),
                    // RecommendedStationsSection(musicas: _recommendedStations),
                    const SizedBox(height: 24),
                    FavoriteArtistsSection(artists: _favoriteArtists),
                    // const SizedBox(height: 24),
                    // PlaylistsSection(playlists: _playlists),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white, // Ícone e texto do item selecionado ficam brancos
        unselectedItemColor: Colors.grey, // Os demais ficam cinza
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            // Home: já está nesta página, não faz nada
          } else if (index == 1) {
            // Navega para a página de busca, substituindo a home para evitar pilha grande
            Navigator.pushReplacementNamed(context, '/search');
          } else if (index == 2) {
            // Navega para a página do usuário (perfil)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UserPage(isCadastro: false),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
