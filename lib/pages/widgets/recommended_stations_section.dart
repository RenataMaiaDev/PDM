import 'package:flutter/material.dart';
import '../components/music_card.dart';

// Widget que representa a seção "Estações Recomendadas"
class RecommendedStationsSection extends StatelessWidget {
  const RecommendedStationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      // Alinha todos os widgets filhos no início do eixo horizontal (esquerda)
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        const Text(
          'Estações Recomendadas',
          style: TextStyle(
            color: Colors.white,        // Cor do texto (branco)
            fontSize: 20,               // Tamanho da fonte
            fontWeight: FontWeight.bold, // Peso da fonte (negrito)
          ),
        ),
        const SizedBox(height: 8), // Espaço entre o título e a lista de cartões
        SizedBox(
          height: 180, // Altura da área onde os cartões serão exibidos
          child: ListView(
            scrollDirection: Axis.horizontal, // Define a rolagem horizontal
            children: const [
              // Cartão da primeira estação recomendada
              MusicCard(
                imageUrl: 'assets/image/1.jpg', // Caminho da imagem da estação
                title: 'Estação 1',             // Nome/título da estação
              ),
              // Cartão da segunda estação recomendada
              MusicCard(
                imageUrl: 'assets/image/1.jpg',
                title: 'Estação 2',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
