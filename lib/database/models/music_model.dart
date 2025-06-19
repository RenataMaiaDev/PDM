import 'dart:typed_data';

class Musica {
  final int? id; // ID da música (pode ser nulo se ainda não foi salva no banco)
  final String titulo; // Título da música
  final String artista; // Nome do artista (como texto)
  final String? album; // Nome do álbum (opcional)
  final Uint8List? capaBytes; // Capa da música em bytes (imagem opcional)
  final int? duracao; // Duração da música em segundos (opcional)
  final String? genero; // Gênero da música (opcional)
  final bool isRecentementeTocada; // Indica se foi tocada recentemente
  final int playCount; // Número de vezes que a música foi reproduzida
  final String? audioPath; // Caminho do arquivo de áudio (opcional)

  Musica({
    this.id,
    required this.titulo,
    required this.artista,
    this.album,
    this.capaBytes,
    this.duracao,
    this.genero,
    this.isRecentementeTocada = false, // Começa como não tocada recentemente
    this.playCount = 0, // Por padrão, ainda não foi tocada
    this.audioPath,
  });

  // Converte o objeto Musica em um Map para salvar no banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'artista': artista,
      'album': album,
      'capa_bytes': capaBytes,
      'duracao': duracao,
      'genero': genero,
      'is_recentemente_tocada': isRecentementeTocada ? 1 : 0, // Armazena como inteiro (0 ou 1)
      'play_count': playCount,
      'audio_path': audioPath,
    };
  }

  // Cria um objeto Musica a partir de um Map vindo do banco de dados
  factory Musica.fromMap(Map<String, dynamic> map) {
    return Musica(
      id: map['id'],
      titulo: map['titulo'],
      artista: map['artista'],
      album: map['album'],
      // Garante que só define a capa se for mesmo uma lista de bytes
      capaBytes: map['capa_bytes'] is Uint8List ? map['capa_bytes'] : null,
      duracao: map['duracao'],
      genero: map['genero'],
      isRecentementeTocada: map['is_recentemente_tocada'] == 1,
      playCount: map['play_count'],
      audioPath: map['audio_path'] as String?, // Pode ser null
    );
  }
}
