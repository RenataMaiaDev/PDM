import 'dart:typed_data';

class Artista {
  final int? id; // ID do artista (pode ser nulo no momento da criação)
  final String nome; // Nome do artista (obrigatório)
  final Uint8List? fotoBytes; // Foto do artista em formato de bytes (opcional)

  Artista({
    this.id,
    required this.nome,
    this.fotoBytes,
  });

  // Converte o objeto Artista para um Map, para salvar no banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'foto_bytes': fotoBytes,
    };
  }

  // Construtor de fábrica para criar um Artista a partir de um Map (como vem do banco)
  factory Artista.fromMap(Map<String, dynamic> map) {
    return Artista(
      id: map['id'], // Recupera o ID
      nome: map['nome'], // Recupera o nome
      // Garante que só converte foto se for Uint8List mesmo
      fotoBytes: map['foto_bytes'] is Uint8List ? map['foto_bytes'] : null,
    );
  }
}
