import 'package:flutter/material.dart';

// Componente reutilizável que representa o card.
class MusicCard extends StatelessWidget {
  // Propriedades obrigatórias: imagem e título
  final String imageUrl;
  final String title;

  const MusicCard({
    super.key,
    required this.imageUrl, // Caminho da imagem local
    required this.title,    // Título a ser exibido abaixo da imagem
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150, // Largura do card
      margin: const EdgeInsets.only(right: 22), // Espaço entre os cards
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Centraliza os elementos na horizontal
        children: [
          // Widget para arredondar a imagem (formato circular/oval)
          ClipRRect(
            borderRadius: BorderRadius.circular(80), // Bordas arredondadas (circular)
            child: Image.asset(
              imageUrl,         // Caminho da imagem (asset)
              height: 150,      // Altura fixa da imagem
              fit: BoxFit.cover, // Ajuste para cobrir o espaço sem distorcer
            ),
          ),

          const SizedBox(height: 8), // Espaço entre imagem e texto

          // Título do card (nome da música, artista ou playlist)
          Text(
            title,
            style: const TextStyle(
              color: Colors.white, // Cor branca
              fontSize: 14,
            ),
            maxLines: 1, // Limita o texto a uma linha
            textAlign: TextAlign.center, // Alinha o texto ao centro
            overflow: TextOverflow.ellipsis, // Adiciona "..." se o texto for muito longo
          ),
        ],
      ),
    );
  }
}
