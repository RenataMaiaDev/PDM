import 'dart:typed_data';

class Playlist {
  final int? id; // ID da playlist (pode ser nulo enquanto ainda não foi salva no banco)
  final String nome; // Nome da playlist (obrigatório)
  final String? descricao; // Descrição da playlist (opcional)
  final Uint8List? capaBytes; // Capa da playlist em formato de bytes (opcional)

  Playlist({
    this.id,
    required this.nome,
    this.descricao,
    this.capaBytes,
  });

  // Converte o objeto Playlist em um Map para salvar no banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'capa_bytes': capaBytes,
    };
  }

  // Construtor de fábrica para criar uma Playlist a partir de um Map (recuperado do banco)
  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'], // Recupera o ID
      nome: map['nome'], // Recupera o nome
      descricao: map['descricao'], // Recupera a descrição
      capaBytes: map['capa_bytes'] is Uint8List ? map['capa_bytes'] : null, // Verifica se é Uint8List antes de atribuir a capa
    );
  }
}
