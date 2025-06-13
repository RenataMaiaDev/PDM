import 'dart:typed_data';

class Usuario {
  int? id;
  String nome;
  String email;
  String senha;
  Uint8List? foto;

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
    this.foto,
  });

  // Converter para Map (para salvar no banco)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'foto': foto,
    };
  }

  // Criar objeto a partir de Map (para ler do banco)
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      senha: map['senha'],
      foto: map['foto'],
    );
  }
}
