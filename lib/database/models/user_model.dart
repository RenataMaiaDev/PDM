import 'dart:typed_data';

class Usuario {
  int? id; // ID do usuário, pode ser nulo ao criar um novo usuário
  String nome; // Nome do usuário (obrigatório)
  String email; // Email do usuário (obrigatório e único)
  String senha; // Senha do usuário (obrigatória)
  Uint8List? foto; // Foto do usuário em bytes (opcional)

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
    this.foto,
  });

  // Transforma o objeto Usuario em um Map para salvar no banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'foto': foto,
    };
  }

  // Cria um objeto Usuario a partir de um Map (usado ao recuperar dados do banco)
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'], // Recupera o ID
      nome: map['nome'], // Recupera o nome
      email: map['email'], // Recupera o email
      senha: map['senha'], // Recupera a senha
      foto: map['foto'], // Recupera a foto (em bytes)
    );
  }
}
