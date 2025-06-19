import 'package:sqflite/sqflite.dart';
import 'package:spotfy/database/data/database_music.dart';
import 'package:spotfy/database/models/playlist_model.dart';
import 'package:spotfy/database/models/music_model.dart';
import 'package:flutter/foundation.dart'; 

class PlaylistRepository {
  final DatabaseMusicHelper _dbHelper = DatabaseMusicHelper();
  // Instancio o helper do banco de dados para acessar as tabelas das playlists

  // Método para inserir uma playlist no banco
  Future<int> insertPlaylist(Playlist playlist) async {
    final db = await _dbHelper.database;
    // Uso conflictAlgorithm.replace para substituir uma playlist existente com o mesmo id
    final id = await db.insert('playlists', playlist.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    debugPrint('PlaylistRepository - Playlist inserida: ${playlist.nome} com ID: $id');
    return id; // Retorno o id da playlist inserida ou atualizada
  }

  // Busca todas as playlists cadastradas no banco
  Future<List<Playlist>> getAllPlaylists() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('playlists');
    // Converte cada mapa retornado em um objeto Playlist
    return List.generate(maps.length, (i) {
      return Playlist.fromMap(maps[i]);
    });
  }

  // Método para adicionar uma música a uma playlist (associação na tabela playlist_musicas)
  Future<void> addMusicToPlaylist(int playlistId, int musicaId) async {
    final db = await _dbHelper.database;
    await db.insert(
      'playlist_musicas',
      {'playlist_id': playlistId, 'musica_id': musicaId},
      conflictAlgorithm: ConflictAlgorithm.replace, // Evita duplicidade na associação
    );
    debugPrint('PlaylistRepository - Música $musicaId adicionada à Playlist $playlistId');
  }

  // Método para obter todas as músicas associadas a uma playlist específica
  Future<List<Musica>> getMusicasFromPlaylist(int playlistId) async {
    final db = await _dbHelper.database;
    // Consulta SQL que junta a tabela de músicas com a tabela de associação para filtrar as músicas da playlist
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT m.* FROM musicas m
      INNER JOIN playlist_musicas pm ON m.id = pm.musica_id
      WHERE pm.playlist_id = ?
    ''', [playlistId]);
    // Converte o resultado em uma lista de objetos Musica
    return List.generate(maps.length, (i) => Musica.fromMap(maps[i]));
  }
}
