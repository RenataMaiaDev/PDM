import 'package:flutter/material.dart';
import 'package:spotfy/database/models/artist_model.dart';
import 'package:spotfy/database/models/music_model.dart';
import 'package:spotfy/database/repositories/music_repository.dart';

import '../widgets/music_list_title.dart';

class ArtistDetailPage extends StatefulWidget {
  // Recebo o artista para exibir detalhes e suas músicas
  final Artista artist;

  const ArtistDetailPage({super.key, required this.artist});

  @override
  State<ArtistDetailPage> createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends State<ArtistDetailPage> {
  final MusicRepository _musicRepo =
      MusicRepository(); // Repositório para buscar músicas no DB
  List<Musica> _artistMusics = []; // Lista para armazenar as músicas do artista
  bool _isLoading = true; // Indicador de carregamento para feedback visual

  @override
  void initState() {
    super.initState();
    // Ao iniciar a página, já carrego as músicas do artista
    _loadArtistMusics();
  }

  Future<void> _loadArtistMusics() async {
    setState(() {
      _isLoading = true; // Ativo o loading enquanto busca os dados
    });
    try {
      // Busco no banco as músicas que têm o nome do artista exato
      final musics = await _musicRepo.getMusicsByArtist(widget.artist.nome);
      debugPrint(
        'ArtistDetailPage - Songs found for ${widget.artist.nome}: ${musics.length}',
      );
      if (mounted) {
        // Verifico se o widget ainda está na tela antes de atualizar o estado
        setState(() {
          _artistMusics = musics; // Atualizo a lista com as músicas encontradas
          _isLoading = false; // Desativo o loading
        });
      }
    } catch (e) {
      // Se ocorrer erro, mostro no debug e exibo uma mensagem para o usuário
      debugPrint('ArtistDetailPage - Error loading songs: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load this artist\'s songs.')),
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
          widget.artist.nome, 
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: _isLoading
          ? const Center(
              // Enquanto estiver carregando, exibe um spinner verde
              child: CircularProgressIndicator(color: Color(0xFF05D853)),
            )
          : _artistMusics.isEmpty
          ? Center(
              // Se não encontrar músicas, mostra mensagem amigável
              child: Text(
                'No songs found for ${widget.artist.nome}.',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _artistMusics.length, // Número de músicas na lista
              itemBuilder: (context, index) {
                final musica = _artistMusics[index];
                // Cada música é exibida usando o widget customizado MusicListTile
                return MusicListTile(musica: musica);
              },
            ),
    );
  }
}
