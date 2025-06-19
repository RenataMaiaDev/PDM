import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotfy/database/data/database_user.dart'; 
import 'package:spotfy/database/models/user_model.dart'; 

class UsuarioRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  // Instancio o helper do banco para acessar a tabela 'usuario'

  static const String _loggedInUserIdKey = 'loggedInUserId';
  // Chave usada para salvar o ID do usuário logado no SharedPreferences

  // Método para inserir um usuário no banco
  Future<int> inserir(Usuario usuario) async {
    final db = await _dbHelper.database;
    final id = await db.insert('usuario', usuario.toMap());
    // Se a inserção foi bem sucedida, já salvo o usuário como logado
    if (id > 0) {
      await _setLoggedInUserId(id);
      debugPrint('UsuarioRepository - Usuário inserido e logado (ID: $id)');
    }
    return id; // Retorno o id inserido
  }

  // Método para listar todos os usuários cadastrados no banco
  Future<List<Usuario>> listar() async {
    final db = await _dbHelper.database;
    final result = await db.query('usuario');
    // Converte cada resultado em objeto Usuario
    return result.map((map) => Usuario.fromMap(map)).toList();
  }

  // Buscar um usuário pelo email (para checar se já existe)
  Future<Usuario?> buscarPorEmail(String email) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'usuario',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return Usuario.fromMap(result.first);
    }
    return null; // Retorna null se não encontrar
  }

  // Método para fazer login: busca usuário pelo email e senha
  Future<Usuario?> login(String email, String senha) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'usuario',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );
    if (result.isNotEmpty) {
      final usuario = Usuario.fromMap(result.first);
      // Se encontrado, salvo o usuário como logado
      await _setLoggedInUserId(usuario.id!);
      debugPrint('UsuarioRepository - Login bem-sucedido. Usuário logado (ID: ${usuario.id})');
      return usuario;
    }
    // Se não encontrou, log de erro e retorno null
    debugPrint('UsuarioRepository - Login falhou: Email ou senha incorretos.');
    return null;
  }

  // Atualizar dados do usuário no banco
  Future<int> atualizar(Usuario usuario) async {
    final db = await _dbHelper.database;
    final rows = await db.update(
      'usuario',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
    final currentLoggedInId = await _getLoggedInUserId();
    // Se o usuário atualizado for o logado, só registro no debug
    if (currentLoggedInId == usuario.id) {
      debugPrint('UsuarioRepository - Usuário logado (ID: ${usuario.id}) atualizado no DB.');
    }
    return rows; // Retorno a quantidade de linhas afetadas
  }

  // Método privado para salvar o ID do usuário logado no SharedPreferences
  Future<void> _setLoggedInUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_loggedInUserIdKey, userId);
    debugPrint('UsuarioRepository - ID do usuário logado salvo em SharedPreferences: $userId');
  }

  // Método privado para recuperar o ID do usuário logado do SharedPreferences
  Future<int?> _getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_loggedInUserIdKey);
    debugPrint('UsuarioRepository - ID do usuário logado lido do SharedPreferences: $userId');
    return userId;
  }

  // Recuperar o usuário logado atual a partir do banco usando o ID salvo
  Future<Usuario?> getUsuarioLogado() async {
    final loggedInUserId = await _getLoggedInUserId();
    if (loggedInUserId != null) {
      final db = await _dbHelper.database;
      final result = await db.query(
        'usuario',
        where: 'id = ?',
        whereArgs: [loggedInUserId],
      );
      if (result.isNotEmpty) {
        final usuario = Usuario.fromMap(result.first);
        debugPrint('UsuarioRepository - Usuário logado recuperado do DB: ${usuario.email}');
        return usuario;
      } else {
        // Caso ID esteja salvo mas usuário não exista no DB, faço logout
        debugPrint('UsuarioRepository - ID logado encontrado, mas usuário não existe no DB. Deslogando...');
        await logout();
      }
    }
    debugPrint('UsuarioRepository - Nenhum usuário logado encontrado.');
    return null;
  }

  // Fazer logout, removendo o ID salvo no SharedPreferences
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInUserIdKey);
    debugPrint('UsuarioRepository - Usuário deslogado (ID removido do SharedPreferences).');
  }
}
