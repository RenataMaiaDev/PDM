import 'package:sqflite/sqflite.dart';
import 'package:spotfy/database/data/database_music.dart';
import 'package:spotfy/database/models/playlist_model.dart';
import 'package:spotfy/database/models/music_model.dart';
import 'package:flutter/foundation.dart'; 

class PlaylistRepository {
  final DatabaseMusicHelper _dbHelper = DatabaseMusicHelper();

  // Insere uma nova playlist no banco de dados.
  //Se uma playlist com o mesmo ID já existir, ela será substituída.
  Future<int> insertPlaylist(Playlist playlist) async {
    final db = await _dbHelper.database;
    final id = await db.insert('playlists', playlist.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    debugPrint('PlaylistRepository - Playlist inserida: ${playlist.nome} com ID: $id');
    return id;
  }

  //Retorna uma lista de todas as playlists cadastradas no banco.
/*************  ✨ Windsurf Command ⭐  *************/
  /// Retorna todas as playlists do banco de dados.
  ///
  /// Retorna uma lista de objetos [Playlist] com todas as playlists
  /// presentes no banco.
/*******  fea0d8f8-47db-4f7b-b61b-0216c6818d23  *******/
  Future<List<Playlist>> getAllPlaylists() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('playlists');
    return List.generate(maps.length, (i) {
      return Playlist.fromMap(maps[i]);
    });
  }

  // Deleta uma playlist e todas as suas músicas associadas.
  Future<void> deletePlaylist(int playlistId) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // Remove todas as músicas associadas a esta playlist da tabela de ligação.
      await txn.delete(
        'playlist_musicas',
        where: 'playlist_id = ?',
        whereArgs: [playlistId],
      );
      // Deleta a playlist da tabela principal 'playlists'.
      await txn.delete(
        'playlists',
        where: 'id = ?',
        whereArgs: [playlistId],
      );
    });
    debugPrint('PlaylistRepository - Playlist com ID $playlistId deletada.');
  }

  // Adiciona uma música a uma playlist específica.
  // Se a música já estiver na playlist, a associação será atualizada.
  Future<void> addMusicToPlaylist(int playlistId, int musicaId) async {
    final db = await _dbHelper.database;
    await db.insert(
      'playlist_musicas',
      {'playlist_id': playlistId, 'musica_id': musicaId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('PlaylistRepository - Música $musicaId adicionada à Playlist $playlistId');
  }

  // Retorna uma lista de todas as músicas que pertencem a uma playlist específica.
  Future<List<Musica>> getMusicasFromPlaylist(int playlistId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT m.* FROM musicas m
      INNER JOIN playlist_musicas pm ON m.id = pm.musica_id
      WHERE pm.playlist_id = ?
    ''', [playlistId]);
    return List.generate(maps.length, (i) => Musica.fromMap(maps[i]));
  }
}