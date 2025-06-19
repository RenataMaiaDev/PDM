import 'package:sqflite/sqflite.dart';
import 'package:spotfy/database/data/database_music.dart';
import 'package:spotfy/database/models/artist_model.dart';
import 'package:flutter/foundation.dart';

class ArtistRepository {
  final DatabaseMusicHelper _dbHelper = DatabaseMusicHelper(); 
  // Instância do helper para acessar o banco de dados de música

  // Método para inserir um artista no banco
  Future<int> insertArtist(Artista artista) async {
    final db = await _dbHelper.database;
    // Uso do conflictAlgorithm.ignore para evitar erro ao tentar inserir
    // artista com nome duplicado (não insere se já existir)
    final id = await db.insert('artistas', artista.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    debugPrint('ArtistRepository - Artista inserido: ${artista.nome} com ID: $id');
    return id;
  }

  // Método para buscar todos os artistas cadastrados
  Future<List<Artista>> getAllArtists() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('artistas');
    // Converte cada Map em um objeto Artista
    return List.generate(maps.length, (i) {
      return Artista.fromMap(maps[i]);
    });
  }

  // Método para pegar artistas favoritos (exemplo: limitados por quantidade)
  Future<List<Artista>> getFavoriteArtists({int limit = 5}) async {
    final db = await _dbHelper.database;
    // Como não tenho uma coluna "is_favorite", pego os primeiros N artistas
    // ordenados por nome em ordem alfabética para simular favoritos
    final List<Map<String, dynamic>> maps = await db.query(
      'artistas',
      orderBy: 'nome ASC',
      limit: limit,
    );
    // Converte os mapas em objetos Artista
    return List.generate(maps.length, (i) {
      return Artista.fromMap(maps[i]);
    });
  }
}
