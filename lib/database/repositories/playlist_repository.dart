// lib/database/repositories/playlist_repository.dart
import 'package:sqflite/sqflite.dart';
import 'package:spotfy/database/data/database_music.dart';
import 'package:spotfy/database/models/playlist_model.dart';
import 'package:spotfy/database/models/music_model.dart';
import 'package:flutter/foundation.dart';

class PlaylistRepository {
  final DatabaseMusicHelper _dbHelper = DatabaseMusicHelper();

  Future<int> insertPlaylist(Playlist playlist) async {
    final db = await _dbHelper.database;
    final id = await db.insert('playlists', playlist.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    debugPrint('PlaylistRepository - Playlist inserida: ${playlist.nome} com ID: $id');
    return id;
  }

  Future<List<Playlist>> getAllPlaylists() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('playlists');
    return List.generate(maps.length, (i) {
      return Playlist.fromMap(maps[i]);
    });
  }

  // --- NOVO MÉTODO: DELETAR PLAYLIST ---
  Future<void> deletePlaylist(int playlistId) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // Primeiro, deleta as associações da playlist com músicas
      await txn.delete(
        'playlist_musicas',
        where: 'playlist_id = ?',
        whereArgs: [playlistId],
      );
      // Depois, deleta a playlist da tabela principal
      await txn.delete(
        'playlists',
        where: 'id = ?',
        whereArgs: [playlistId],
      );
    });
    debugPrint('PlaylistRepository - Playlist com ID $playlistId deletada (e suas músicas associadas).');
  }
  // --- FIM DO NOVO MÉTODO ---

  Future<void> addMusicToPlaylist(int playlistId, int musicaId) async {
    final db = await _dbHelper.database;
    await db.insert(
      'playlist_musicas',
      {'playlist_id': playlistId, 'musica_id': musicaId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('PlaylistRepository - Música $musicaId adicionada à Playlist $playlistId');
  }

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