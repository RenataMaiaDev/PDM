import 'package:flutter/material.dart';
import 'package:spotfy/database/models/music_model.dart';
import 'package:spotfy/database/models/artist_model.dart';
import 'package:spotfy/database/repositories/music_repository.dart';
import 'package:spotfy/database/repositories/artist_repository.dart';
import 'package:spotfy/pages/screen/playlists_screen.dart';
import 'package:spotfy/pages/screen/user.dart';
import 'package:spotfy/database/utils/profile_notifier.dart'; 
import '../widgets/favorite_artists_section.dart';
import '../widgets/recent_musics_section.dart';
import '../widgets/top_musics_section.dart';
import '../widgets/user_avatar.dart';
import '../widgets/app_drawer.dart';

// Tela principal da aplicação, exibindo conteúdos como músicas e artistas.
// Atua como o hub central de navegação e exibição de dados.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Estado da HomePage, responsável por gerenciar os dados exibidos e interações.
class _HomePageState extends State<HomePage> {
  // Repositórios para acessar e manipular dados de música e artistas do banco de dados.
  final MusicRepository _musicRepo = MusicRepository();
  final ArtistRepository _artistRepo = ArtistRepository();

  // Chave global para acessar o Scaffold (necessária para abrir o EndDrawer).
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Listas para armazenar os dados que serão exibidos nas seções da Home.
  List<Musica> _recentMusics = [];
  List<Musica> _topMusics = [];
  List<Artista> _favoriteArtists = [];

  // Flag para controlar o estado de carregamento da página.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inicia o carregamento dos dados da página principal.
    _loadHomePageData();
    // Adiciona um listener ao ProfileNotifier. Isso permite que a HomePage
    // reaja a mudanças no perfil do usuário (ex: foto ou nome atualizados na UserPage)
    // e atualize a UI correspondente (avatar, drawer).
    profileNotifier.addListener(_onProfileOrLogoutUpdated);
  }

  @override
  void dispose() {
    // É fundamental remover o listener do ProfileNotifier ao descartar o widget.
    // Isso previne vazamentos de memória e comportamentos inesperados.
    profileNotifier.removeListener(_onProfileOrLogoutUpdated);
    super.dispose();
  }

  /// Carrega os dados para as seções da HomePage (músicas recentes, top músicas, artistas).
  /// Define o estado de carregamento e trata possíveis erros.
  Future<void> _loadHomePageData() async {
    setState(() {
      _isLoading = true; // Inicia o carregamento, mostrando o CircularProgressIndicator.
    });
    try {
      // Busca os dados nos respectivos repositórios.
      final recent = await _musicRepo.getRecentMusicas(limit: 5);
      final top = await _musicRepo.getTopMusicas(limit: 6);
      final artists = await _artistRepo.getFavoriteArtists(limit: 6);

      // Garante que o widget ainda está montado antes de chamar setState,
      // prevenindo erros caso a tela seja descartada durante o Future.
      if (mounted) {
        setState(() {
          _recentMusics = recent;
          _topMusics = top;
          _favoriteArtists = artists;
          _isLoading = false; // Carregamento concluído.
        });
      }
    } catch (e) {
      debugPrint('HomePage - Erro ao carregar dados: $e');
      if (mounted) {
        setState(() {
          _isLoading = false; // Em caso de erro, desativa o indicador de carregamento.
        });
        // Exibe uma SnackBar para informar o usuário sobre o erro.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar dados da página inicial. Tente novamente.'),
          ),
        );
      }
    }
  }

  // Callback chamado quando o ProfileNotifier notifica uma atualização.
  void _onProfileOrLogoutUpdated() {
    debugPrint('Notificação de perfil recebida na HomePage.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Associa a chave ao Scaffold para controle do Drawer.
      backgroundColor: Colors.black, // Define o fundo da tela como preto.
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0, // Remove a sombra da AppBar para um visual mais limpo.
        title: const Text(
          'Spotify',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          // Exibe o avatar do usuário. Este widget escuta o ProfileNotifier e
          // usa a _scaffoldKey para abrir o EndDrawer quando clicado.
          UserAvatar(scaffoldKey: _scaffoldKey),
        ],
      ),
      // O menu lateral (Drawer), que desliza da direita para a esquerda.
      // Ele também escuta o ProfileNotifier para exibir o nome e a foto do usuário.
      endDrawer: AppDrawer(onProfileUpdated: _onProfileOrLogoutUpdated),
      body: _isLoading // Se estiver carregando, mostra um indicador de progresso.
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF05D853)),
            )
          : RefreshIndicator( // Permite ao usuário puxar para baixo para recarregar os dados.
              onRefresh: _loadHomePageData,
              color: const Color(0xFF05D853), // Cor do indicador de refresh.
              child: SingleChildScrollView( // Permite rolagem se o conteúdo for maior que a tela.
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Alinha o conteúdo à esquerda.
                  children: [
                    // Seções de conteúdo dinâmico da Home.
                    FavoriteArtistsSection(artists: _favoriteArtists),
                    const SizedBox(height: 11),
                    RecentMusicsSection(musics: _recentMusics),
                    const SizedBox(height: 11),
                    TopMusicsSection(musics: _topMusics),
                    const SizedBox(height: 11),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar( // Barra de navegação inferior.
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white, // Cor do item selecionado.
        unselectedItemColor: Colors.grey, // Cor dos itens não selecionados.
        type: BottomNavigationBarType.fixed, // Garante que todos os itens apareçam igualmente.
        onTap: (index) {
          if (index == 0) {
            // Se "Home" for clicado, não faz nada pois já está na Home.
          } else if (index == 1) {
            // Navega para a tela de Playlists.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlaylistsScreen()),
            ).then((_) {
              // Quando o usuário volta da tela de Playlists, recarrega os dados da Home.
              _loadHomePageData();
            });
          } else if (index == 2) {
            // Navega para a tela de Perfil (UserPage) no modo de edição.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UserPage(isCadastro: false),
              ),
            ).then((_) {
              // Ao retornar da UserPage (onde o perfil pode ter sido atualizado),
              // notifica o ProfileNotifier para que o avatar e o drawer se atualizem.
              profileNotifier.notifyProfileUpdate();
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.queue_music),
            label: 'Playlists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}