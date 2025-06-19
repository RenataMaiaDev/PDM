import 'package:flutter/material.dart';
import 'package:spotfy/database/models/artist_model.dart';

import '../screen/artist_detail.dart' show ArtistDetailPage;

class MusicCard extends StatelessWidget {
  final Artista artist; // Recebo o objeto Artista completo para exibir suas informações

  const MusicCard({
    super.key,
    required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Quando o usuário clicar no card, navego para a tela de detalhes do artista,
        // passando o objeto artista para carregar as músicas e informações dele
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistDetailPage(artist: artist),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Centralizo o texto abaixo da imagem para manter alinhamento visual
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[800], 
              shape: BoxShape.circle,   
              image: artist.fotoBytes != null
                  ? DecorationImage(
                      image: MemoryImage(artist.fotoBytes!), 
                      fit: BoxFit.cover,                      
                    )
                  : null, // Se não tiver imagem, deixo sem decoração para mostrar o ícone padrão
            ),
            // Se não houver foto, mostro um ícone padrão de pessoa com cor clara para indicar ausência de imagem
            child: artist.fotoBytes == null
                ? const Icon(Icons.person, color: Colors.white54, size: 60)
                : null,
          ),
          const SizedBox(height: 8), 
          SizedBox(
            width: 120,
            child: Text(
              artist.nome, 
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center, 
              overflow: TextOverflow.ellipsis, 
              maxLines: 1, 
            ),
          ),
        ],
      ),
    );
  }
}
