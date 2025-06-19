import 'package:sqflite/sqflite.dart';
import 'package:spotfy/database/data/database_music.dart';
import 'package:spotfy/database/models/music_model.dart';
import 'package:flutter/foundation.dart';

class MusicRepository {
  final DatabaseMusicHelper _dbHelper = DatabaseMusicHelper();
  // Instancia o helper do banco para acessar o banco de músicas

  // Método para inserir uma música no banco
  Future<int> insertMusic(Musica musica) async {
    final db = await _dbHelper.database;
    // Usa conflictAlgorithm.replace para substituir a música se já existir com o mesmo id
    final id = await db.insert('musicas', musica.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    debugPrint('MusicRepository - Música inserida: ${musica.titulo} com ID: $id');
    return id; // Retorna o id da música inserida/atualizada
  }

  // Busca todas as músicas do banco
  Future<List<Musica>> getAllMusicas() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('musicas');
    // Converte cada mapa retornado em um objeto Musica
    return List.generate(maps.length, (i) {
      return Musica.fromMap(maps[i]);
    });
  }

  // Busca as músicas marcadas como recentemente tocadas, limitando o número
  Future<List<Musica>> getRecentMusicas({int limit = 5}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'musicas',
      where: 'is_recentemente_tocada = ?', // Filtra só as recentes
      whereArgs: [1], // 1 representa true nesse caso
      orderBy: 'id DESC', // Ordena do mais recente para o mais antigo
      limit: limit,
    );
    return List.generate(maps.length, (i) {
      return Musica.fromMap(maps[i]);
    });
  }

  // Busca as músicas mais tocadas, limitando o número
  Future<List<Musica>> getTopMusicas({int limit = 5}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'musicas',
      orderBy: 'play_count DESC', // Ordena do mais tocado para o menos tocado
      limit: limit,
    );
    return List.generate(maps.length, (i) {
      return Musica.fromMap(maps[i]);
    });
  }

  // Busca músicas pelo nome do artista (ex: todas as músicas do "Artista X")
  Future<List<Musica>> getMusicsByArtist(String artistName) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'musicas',
      where: 'artista = ?', // Filtra por nome do artista
      whereArgs: [artistName],
      orderBy: 'titulo ASC', // Ordena as músicas pelo título em ordem alfabética
    );
    return List.generate(maps.length, (i) {
      return Musica.fromMap(maps[i]);
    });
  } 
}
