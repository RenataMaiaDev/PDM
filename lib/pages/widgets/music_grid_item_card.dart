import 'package:flutter/material.dart';
import 'package:spotfy/database/models/music_model.dart'; 
import 'package:spotfy/pages/widgets/music_player.dart'; 

/// Este é o widget [MusicGridItemCard], que eu uso para exibir cada música
/// na minha grade de músicas, como um card individual.
class MusicGridItemCard extends StatelessWidget {
  final Musica music; // Recebo o objeto 'Musica' para exibir seus dados.

  const MusicGridItemCard({super.key, required this.music});

  @override
  Widget build(BuildContext context) {
    // Eu envolvo todo o card em um GestureDetector para poder reagir a toques.
    return GestureDetector(
      onTap: () {
        // Quando eu toco no card, eu verifico se a música tem um arquivo de áudio.
        if (music.audioPath != null && music.audioPath!.isNotEmpty) {
        } else {
          // Se a música não tiver um arquivo de áudio, eu aviso o usuário com um SnackBar.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Música sem arquivo de áudio para tocar.'),
            ),
          );
        }
      },
      // Eu organizo o conteúdo do card em uma coluna.
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Eu quero que o texto comece alinhado à esquerda.
        children: [
          // Eu uso um Stack para poder colocar o botão de play por cima da capa da música.
          Stack(
            children: [
              // Esta é a área da capa da música.
              Container(
                width: 140, // Eu defino uma largura fixa para o card.
                height: 140, // E uma altura fixa para a área da capa.
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      8, // Eu arredondo as bordas para um visual mais suave.
                  ),
                  color: Colors.grey[800], // Defino uma cor de fundo padrão se não houver capa.
                  // Se a música tiver dados de capa (bytes), eu os uso como imagem de fundo.
                  image: music.capaBytes != null
                      ? DecorationImage(
                          image: MemoryImage(
                              music.capaBytes!, // Uso MemoryImage porque são bytes.
                          ),
                          fit: BoxFit.cover, // Faço a imagem cobrir todo o espaço.
                        )
                      : null, // Se não tiver capa, deixo sem imagem.
                ),
                // Se não houver capa, eu mostro um ícone de nota musical no centro.
                child: music.capaBytes == null
                    ? const Icon(
                        Icons.music_note,
                        color: Colors.white54, // Cor suave para o ícone padrão.
                        size: 60,
                      )
                    : null, // Se tiver capa, não mostro nada aqui.
              ),
              // Este é o botão de Play, que eu posiciono no canto inferior direito.
              // Eu só mostro o botão se a música tiver um 'audioPath'.
              if (music.audioPath != null && music.audioPath!.isNotEmpty)
                Positioned(
                  bottom: 2, // Coloco ele um pouco acima da borda inferior.
                  right: 2, // E um pouco para a esquerda da borda direita.
                  child: MusicPlayerButton(
                    audioPath: music.audioPath!, // Passo o caminho do áudio para o player.
                    musicTitle: music.titulo, // Passo o título da música para o player.
                    iconSize: 30, // Defino o tamanho do ícone do botão.
                    iconColor: Colors.greenAccent[400]!, // Uso uma cor verde vibrante, como a do Spotify.
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8), // Um pequeno espaço entre a capa e o título.
          // Este é o Título da Música.
          SizedBox(
            width: 140, // Defino a mesma largura da capa para o texto.
            child: Text(
              music.titulo,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 1, // Limito a uma linha.
              overflow:
                  TextOverflow.ellipsis, // Se o título for muito longo, eu corto com reticências.
            ),
          ),
          // Este é o Nome do Artista.
          SizedBox(
            width: 140, // Também com a mesma largura da capa.
            child: Text(
              music.artista,
              style: TextStyle(color: Colors.grey[400], fontSize: 12), // Cor mais clara e fonte menor.
              maxLines: 1, // Limito a uma linha.
              overflow: TextOverflow.ellipsis, // Corto com reticências se for longo.
            ),
          ),
        ],
      ),
    );
  }
}