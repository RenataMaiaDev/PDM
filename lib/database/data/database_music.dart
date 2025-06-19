import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DatabaseMusicHelper {
  // Singleton: garante que só exista uma instância do helper
  static final DatabaseMusicHelper _instance = DatabaseMusicHelper._internal();
  factory DatabaseMusicHelper() => _instance;
  DatabaseMusicHelper._internal();

  static Database? _database;

  // Getter que retorna o banco de dados já inicializado (ou inicializa se ainda não estiver)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  // Método para inicializar o banco de dados
  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath(); // Caminho padrão do SQLite
    final path = join(databasePath, 'spotify_music.db'); // Nome do arquivo do banco
    debugPrint('DatabaseMusicHelper - Path do banco de dados: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Caso precise fazer upgrades no futuro
      onOpen: (db) {
        debugPrint('DatabaseMusicHelper - Banco de dados aberto.');
      }
    );
  }

  // Método executado quando o banco é criado pela primeira vez
  Future<void> _onCreate(Database db, int version) async {
    // Criação da tabela de músicas
    await db.execute('''
      CREATE TABLE IF NOT EXISTS musicas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        artista TEXT NOT NULL,
        album TEXT,
        capa_bytes BLOB,
        duracao INTEGER,
        genero TEXT,
        is_recentemente_tocada INTEGER DEFAULT 0,
        play_count INTEGER DEFAULT 0,
        audio_path TEXT
      )
    ''');

    // Criação da tabela de artistas
    await db.execute('''
      CREATE TABLE IF NOT EXISTS artistas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL UNIQUE,
        foto_bytes BLOB
      )
    ''');

    // Criação da tabela de playlists
    await db.execute('''
      CREATE TABLE IF NOT EXISTS playlists(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL UNIQUE,
        descricao TEXT,
        capa_bytes BLOB
      )
    ''');

    // Criação da tabela que faz a associação entre playlists e músicas (N:N)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS playlist_musicas(
        playlist_id INTEGER,
        musica_id INTEGER,
        PRIMARY KEY (playlist_id, musica_id),
        FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
        FOREIGN KEY (musica_id) REFERENCES musicas(id) ON DELETE CASCADE
      )
    ''');

    debugPrint('DatabaseMusicHelper - Tabelas criadas: musicas, artistas, playlists, playlist_musicas');
  }

  // Método chamado quando houver necessidade de fazer upgrade de versão do banco
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('DatabaseMusicHelper - Atualizando DB de versão $oldVersion para $newVersion');
    // Exemplo de como tratar atualizações de esquema entre versões
    if (oldVersion < 2 && newVersion >= 2) {
      // Aqui eu poderia adicionar colunas, por exemplo
      debugPrint('DatabaseMusicHelper - Exemplo de upgrade: Adicionando coluna audio_path.');
    }
  }

  // Método que deleta o arquivo físico do banco de dados
  Future<void> deleteDatabaseFile() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'spotify_music.db');
    debugPrint('DatabaseMusicHelper - Tentando deletar o arquivo do banco de dados: $path');
    try {
      await deleteDatabase(path);
      _database = null; // Reseta a instância interna para garantir reabertura correta depois
      debugPrint('DatabaseMusicHelper - Arquivo do banco de dados deletado com sucesso!');
    } catch (e) {
      debugPrint('DatabaseMusicHelper - Erro ao deletar o arquivo do banco de dados: $e');
    }
  }

  // Método que limpa todas as tabelas do banco (mas mantém a estrutura intacta)
  Future<void> clearAllMusicData() async {
    final db = await database;
    await db.delete('musicas');
    await db.delete('artistas');
    await db.delete('playlists');
    await db.delete('playlist_musicas');
    debugPrint('DatabaseMusicHelper - Todos os dados de música (tabelas) foram limpos.');
  }
}
