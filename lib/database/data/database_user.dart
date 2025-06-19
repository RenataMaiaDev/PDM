import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton para garantir que só uma instância do banco seja usada em todo o app
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  // Getter para acessar o banco. Se ele já estiver aberto, retorna direto. Senão, inicializa.
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  // Inicializa o banco de dados
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath(); // Pega o caminho onde os bancos ficam salvos
    final path = join(dbPath, 'usuarios.db'); // Define o nome do arquivo do banco

    // Abre (ou cria) o banco de dados
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate, // Chama esse método se o banco ainda não existir
    );
  }

  // Método que cria a tabela "usuario" na primeira vez que o banco for criado
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID auto-incrementado
        nome TEXT NOT NULL,                    -- Nome obrigatório
        email TEXT NOT NULL UNIQUE,            -- Email obrigatório e único
        senha TEXT NOT NULL,                   -- Senha obrigatória
        foto BLOB                              -- Foto do usuário (opcional), salva como bytes
      )
    ''');
  }
}
