import 'package:flutter/material.dart';
import '../components/music_card.dart';

// Widget que representa a seção "Tocados Recentemente"
class RecentSection extends StatelessWidget {
  const RecentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      // Alinha os elementos no início do eixo horizontal (esquerda)
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        const Text(
          'Tocados Recentemente',
          style: TextStyle(
            color: Colors.white,        // Cor do texto
            fontSize: 20,               // Tamanho da fonte
            fontWeight: FontWeight.bold, // Fonte em negrito
          ),
        ),
        const SizedBox(height: 8), // Espaço vertical entre o título e a lista
        SizedBox(
          height: 180, // Altura da lista de músicas
          child: ListView(
            scrollDirection: Axis.horizontal, // Rolagem horizontal da lista
            children: const [
              // Cartão representando a primeira música recentemente tocada
              MusicCard(
                imageUrl: 'assets/image/1.jpg', // Caminho da imagem da música
                title: 'Música 1',              // Título da música
              ),
              // Cartão representando a segunda música
              MusicCard(
                imageUrl: 'assets/image/1.jpg',
                title: 'Música 2',
              ),
              // Cartão representando a terceira música
              MusicCard(
                imageUrl: 'assets/image/1.jpg',
                title: 'Música 3',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
