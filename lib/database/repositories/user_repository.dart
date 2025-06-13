import 'package:spotfy/database/data/database_user.dart';
import 'package:spotfy/database/models/user_model.dart';

class UsuarioRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> inserir(Usuario usuario) async {
    final db = await _dbHelper.database;
    return await db.insert('usuario', usuario.toMap());
  }

  Future<List<Usuario>> listar() async {
    final db = await _dbHelper.database;
    final result = await db.query('usuario');
    return result.map((map) => Usuario.fromMap(map)).toList();
  }

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
    return null;
  }

  Future<Usuario?> login(String email, String senha) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'usuario',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );
    if (result.isNotEmpty) {
      return Usuario.fromMap(result.first);
    }
    return null;
  }

  Future<int> deletar(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('usuario', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> atualizar(Usuario usuario) async {
    final db = await _dbHelper.database;
    return await db.update(
      'usuario',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }
}
