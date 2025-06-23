// ignore_for_file: unused_local_variable

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart'; 
import 'package:spotfy/database/models/music_model.dart';
import 'package:spotfy/database/models/artist_model.dart';
import 'package:spotfy/database/models/playlist_model.dart';
import 'package:spotfy/database/repositories/music_repository.dart';
import 'package:spotfy/database/repositories/artist_repository.dart';
import 'package:spotfy/database/repositories/playlist_repository.dart';

// Função auxiliar para carregar uma imagem do asset e retornar em bytes
Future<Uint8List?> _loadImageAsBytes(String assetPath) async {
  try {
    final byteData = await rootBundle.load(assetPath);
    return byteData.buffer.asUint8List();
  } catch (e) {
    debugPrint('Erro ao carregar imagem do asset "$assetPath": $e');
    return null; // Retorna null se não conseguir carregar
  }
}

// Função principal que faz o "seed" dos dados iniciais na base de dados
Future<void> seedMusicData() async {
  // Instancio os repositórios que vão lidar com as tabelas no banco
  final musicRepo = MusicRepository();
  final artistRepo = ArtistRepository();
  final playlistRepo = PlaylistRepository();

  debugPrint('Iniciando o seeding de dados...');

  // Carrego as capas de álbum para usar nas músicas e artistas
  final Uint8List? defaultCover = await _loadImageAsBytes('assets/image/placeholder_album.png');
  final Uint8List? beatlesCover = await _loadImageAsBytes('assets/image/beatles.jpeg');
  final Uint8List? queenCover = await _loadImageAsBytes('assets/image/queen.jpeg');
  final Uint8List? adeleCover = await _loadImageAsBytes('assets/image/adele.jpeg');
  final Uint8List? edSheeranCover = await _loadImageAsBytes('assets/image/ed.jpeg');
  final Uint8List? duaLipaCover = await _loadImageAsBytes('assets/image/dua_lipa.jpeg');
  final Uint8List? ledZeppelinCover = await _loadImageAsBytes('assets/image/led.jpeg');

  // INSERINDO ARTISTAS - muito importante que o nome do artista seja exatamente igual ao usado nas músicas
  final int artistBeatlesId = await artistRepo.insertArtist(Artista(nome: 'The Beatles', fotoBytes: beatlesCover ?? defaultCover));
  final int artistQueenId = await artistRepo.insertArtist(Artista(nome: 'Queen', fotoBytes: queenCover ?? defaultCover));
  final int artistAdeleId = await artistRepo.insertArtist(Artista(nome: 'Adele', fotoBytes: adeleCover ?? defaultCover));
  final int artistEdSheeranId = await artistRepo.insertArtist(Artista(nome: 'Ed Sheeran', fotoBytes: edSheeranCover ?? defaultCover));
  final int artistDuaLipaId = await artistRepo.insertArtist(Artista(nome: 'Dua Lipa', fotoBytes: duaLipaCover ?? defaultCover));
  final int artistLedZeppelinId = await artistRepo.insertArtist(Artista(nome: 'Led Zeppelin', fotoBytes: ledZeppelinCover ?? defaultCover));

  // INSERINDO MÚSICAS - notar que o campo 'artista' tem que bater com os nomes dos artistas inseridos acima
  final int musicBohemianId = await musicRepo.insertMusic(Musica(
    titulo: 'Bohemian Rhapsody',
    artista: 'Queen',
    album: 'A Night at the Opera',
    capaBytes: queenCover ?? defaultCover,
    duracao: 354, // duração em segundos (5:54)
    genero: 'Rock',
    playCount: 150,
    isRecentementeTocada: true,
    audioPath: 'audio/musica1.mp3',
  ));
  final int musicHeyJudeId = await musicRepo.insertMusic(Musica(
    titulo: 'Hey Jude',
    artista: 'The Beatles',
    album: 'Past Masters',
    capaBytes: beatlesCover ?? defaultCover,
    duracao: 421,
    genero: 'Pop/Rock',
    playCount: 120,
    isRecentementeTocada: true,
    audioPath: 'audio/musica1.mp3',
  ));
  final int musicSomeoneLikeYouId = await musicRepo.insertMusic(Musica(
    titulo: 'Someone Like You',
    artista: 'Adele',
    album: '21',
    capaBytes: adeleCover ?? defaultCover,
    duracao: 285,
    genero: 'Pop',
    playCount: 180,
    isRecentementeTocada: true,
    audioPath: 'audio/musica1.mp3',
  ));
  final int musicStairwayId = await musicRepo.insertMusic(Musica(
    titulo: 'Stairway to Heaven',
    artista: 'Led Zeppelin',
    album: 'Led Zeppelin IV',
    capaBytes: ledZeppelinCover ?? defaultCover,
    duracao: 482,
    genero: 'Rock',
    playCount: 90,
    audioPath: 'audio/musica1.mp3',
  ));
  final int musicShapeOfYouId = await musicRepo.insertMusic(Musica(
    titulo: 'Shape of You',
    artista: 'Ed Sheeran',
    album: '÷',
    capaBytes: edSheeranCover ?? defaultCover,
    duracao: 233,
    genero: 'Pop',
    playCount: 200,
    audioPath: 'audio/musica1.mp3',
  ));
  final int musicDontStopMeNowId = await musicRepo.insertMusic(Musica(
    titulo: 'Don\'t Stop Me Now',
    artista: 'Queen',
    album: 'Jazz',
    capaBytes: queenCover ?? defaultCover,
    duracao: 210,
    genero: 'Rock',
    playCount: 130,
    audioPath: 'audio/musica1.mp3',
  ));
  final int musicYesterdayId = await musicRepo.insertMusic(Musica(
    titulo: 'Yesterday',
    artista: 'The Beatles',
    album: 'Help!',
    capaBytes: beatlesCover ?? defaultCover,
    duracao: 125,
    genero: 'Pop',
    playCount: 80,
    isRecentementeTocada: true,
    audioPath: 'audio/musica1.mp3',
  ));
  final int musicLevitatingId = await musicRepo.insertMusic(Musica(
    titulo: 'Levitating',
    artista: 'Dua Lipa',
    album: 'Future Nostalgia',
    capaBytes: duaLipaCover ?? defaultCover,
    duracao: 203,
    genero: 'Pop',
    playCount: 170,
    audioPath: 'audio/musica1.mp3',
  ));

  // INSERINDO PLAYLISTS - capa padrão ou específica, com nome e descrição
  final int playlistFavoritesId = await playlistRepo.insertPlaylist(Playlist(nome: 'Minhas Escolhas', descricao: 'As melhores músicas pra mim!', capaBytes: defaultCover));
  final int playlistClassicRockId = await playlistRepo.insertPlaylist(Playlist(nome: 'Rock Clássico', descricao: 'Hinos atemporais do Rock', capaBytes: ledZeppelinCover ?? defaultCover));
  final int playlistPopHitsId = await playlistRepo.insertPlaylist(Playlist(nome: 'Pop Atual', descricao: 'Os maiores sucessos do Pop', capaBytes: duaLipaCover ?? defaultCover));

  // ASSOCIAÇÃO DE MÚSICAS NAS PLAYLISTS - adiciono as músicas que combinam com cada playlist
  if (playlistFavoritesId > 0) {
    await playlistRepo.addMusicToPlaylist(playlistFavoritesId, musicBohemianId);
    await playlistRepo.addMusicToPlaylist(playlistFavoritesId, musicHeyJudeId);
    await playlistRepo.addMusicToPlaylist(playlistFavoritesId, musicSomeoneLikeYouId);
  }

  if (playlistClassicRockId > 0) {
    await playlistRepo.addMusicToPlaylist(playlistClassicRockId, musicBohemianId);
    await playlistRepo.addMusicToPlaylist(playlistClassicRockId, musicStairwayId);
    await playlistRepo.addMusicToPlaylist(playlistClassicRockId, musicDontStopMeNowId);
  }

  if (playlistPopHitsId > 0) {
    await playlistRepo.addMusicToPlaylist(playlistPopHitsId, musicShapeOfYouId);
    await playlistRepo.addMusicToPlaylist(playlistPopHitsId, musicLevitatingId);
    await playlistRepo.addMusicToPlaylist(playlistPopHitsId, musicSomeoneLikeYouId);
  }

  debugPrint('Seeding de dados concluído com sucesso!');
}
