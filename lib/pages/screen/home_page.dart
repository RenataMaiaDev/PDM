import 'package:flutter/material.dart';
// Importa as seções personalizadas usadas na tela principal
import '../widgets/recent_section.dart';
import '../widgets/top_music_section.dart';
import '../widgets/recommended_stations_section.dart';
import '../widgets/favorite_artists_section.dart';
import '../widgets/playlists_section.dart';

// Widget principal da tela inicial do aplicativo
class HomePage extends StatelessWidget {
  const HomePage({super.key}); // Construtor da classe

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Cor de fundo da tela

      // Barra superior (AppBar) com título estilizado
      appBar: AppBar(
        backgroundColor: Colors.black, // Cor de fundo da AppBar
        elevation: 0, // Remove a sombra da AppBar
        title: const Text(
          'Spotify', // Título exibido na AppBar
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold, 
            fontSize: 24,               
          ),
        ),
      ),

      // Corpo da página com rolagem vertical
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Espaçamento interno
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Alinha os widgets à esquerda
          children: [
            RecentSection(),              // Seção de músicas tocadas recentemente
            SizedBox(height: 24),        
            TopMusicSection(),            // Seção de músicas mais ouvidas
            SizedBox(height: 24),
            RecommendedStationsSection(), // Seção de estações recomendadas
            SizedBox(height: 24),
            FavoriteArtistsSection(),     // Seção de artistas favoritos
            SizedBox(height: 24),
            PlaylistsSection(),           // Seção de playlists do usuário
          ],
        ),
      ),

      // Barra de navegação inferior (BottomNavigationBar)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,       // Cor de fundo da barra
        selectedItemColor: Colors.white,     // Cor do ícone/texto selecionado
        unselectedItemColor: Colors.grey,    // Cor dos itens não selecionados
        type: BottomNavigationBarType.fixed, // Fixa todos os ícones na barra
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início', // Ícone e rótulo da aba "Início"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar', // Aba de pesquisa
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Biblioteca', // Biblioteca de músicas
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Criar', // Aba para criar conteúdo
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.workspace_premium),
            label: 'Premium', // Aba para plano Premium
          ),
        ],
      ),
    );
  }
}
