// lib/pages/screen/home_page.dart
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MusicRepository _musicRepo = MusicRepository();
  final ArtistRepository _artistRepo = ArtistRepository();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Musica> _recentMusics = [];
  List<Musica> _topMusics = [];
  List<Artista> _favoriteArtists = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomePageData();
    // Adicione um listener ao profileNotifier para reagir a mudanças no perfil
    profileNotifier.addListener(_onProfileOrLogoutUpdated);
  }

  @override
  void dispose() {
    // É crucial remover o listener para evitar vazamentos de memória
    profileNotifier.removeListener(_onProfileOrLogoutUpdated);
    super.dispose();
  }

  Future<void> _loadHomePageData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final recent = await _musicRepo.getRecentMusicas(limit: 5);
      final top = await _musicRepo.getTopMusicas(limit: 6);
      final artists = await _artistRepo.getFavoriteArtists(limit: 6);

      if (mounted) {
        setState(() {
          _recentMusics = recent;
          _topMusics = top;
          _favoriteArtists = artists;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('HomePage - Erro ao carregar dados: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar dados da página inicial. Tente novamente.'),
          ),
        );
      }
    }
  }

  // Este método será chamado quando o perfil for atualizado ou após um logout
  void _onProfileOrLogoutUpdated() {
    debugPrint('Notificação de perfil recebida na HomePage.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Spotify',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          // UserAvatar agora dependerá da notificação do profileNotifier
          UserAvatar(scaffoldKey: _scaffoldKey),
        ],
      ),
      // AppDrawer também dependerá da notificação do profileNotifier
      endDrawer: AppDrawer(onProfileUpdated: _onProfileOrLogoutUpdated),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF05D853)),
            )
          : RefreshIndicator(
              onRefresh: _loadHomePageData,
              color: const Color(0xFF05D853),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            // Home (já está aqui)
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlaylistsScreen()),
            ).then((_) {
              _loadHomePageData(); // Recarrega dados ao voltar da tela de Playlists
            });
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UserPage(isCadastro: false),
              ),
            ).then((_) {
              // >>> Importante: Notifica que o perfil pode ter sido atualizado <<<
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