import 'package:flutter/material.dart';
import '../components/music_card.dart';

// Widget que representa a seção "Músicas Mais Ouvidas"
class TopMusicSection extends StatelessWidget {
  const TopMusicSection({super.key}); // Construtor da classe com uma chave opcional

  @override
  Widget build(BuildContext context) {
    return Column(
      // Alinha os elementos no início do eixo horizontal (esquerda)
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        const Text(
          'Músicas Mais Ouvidas', // Texto do título da seção
          style: TextStyle(
            color: Colors.white,         // Cor do texto
            fontSize: 20,                // Tamanho da fonte
            fontWeight: FontWeight.bold, // Negrito para destacar
          ),
        ),
        const SizedBox(height: 8), // Espaço vertical entre o título e a lista de músicas
        SizedBox(
          height: 180, // Altura do container da lista de músicas
          child: ListView(
            scrollDirection: Axis.horizontal, // Permite rolagem horizontal
            children: const [
              // Cartão representando a primeira música mais ouvida
              MusicCard(
                imageUrl: 'assets/image/1.jpg', // Caminho da imagem da música
                title: 'Top Música 1',          // Título da música
              ),
              // Cartão representando a segunda música mais ouvida
              MusicCard(
                imageUrl: 'assets/image/1.jpg',
                title: 'Top Música 2',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
