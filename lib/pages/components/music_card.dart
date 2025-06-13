import 'package:flutter/material.dart';

// Widget que representa o card
class MusicCard extends StatelessWidget {
  // Propriedades obrigatórias: caminho da imagem e título do card
  final String imageUrl;
  final String title;

  const MusicCard({
    super.key,
    required this.imageUrl, // Caminho da imagem local no app
    required this.title,    // Título exibido abaixo da imagem
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160, // Largura fixa do card para manter padrão visual
      margin: const EdgeInsets.only(right: 22), // Espaço à direita para separar cards em listas horizontais
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Centraliza conteúdo horizontalmente
        children: [
          // Imagem com cantos arredondados (borda com raio 8)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imageUrl,       // Imagem exibida (carregada dos assets)
              height: 150,    // Altura fixa para manter padrão visual
              fit: BoxFit.cover, // Ajusta a imagem para cobrir todo o espaço sem distorção
            ),
          ),

          const SizedBox(height: 8), // Espaçamento entre a imagem e o texto

          // Texto do título do card
          Text(
            title,
            style: const TextStyle(
              color: Colors.white, // Cor branca para o texto
              fontSize: 14,        // Tamanho da fonte
            ),
            textAlign: TextAlign.center, // Centraliza o texto no card
            maxLines: 1,                  // Limita o texto a uma linha
            overflow: TextOverflow.ellipsis, // Adiciona "..." se o texto for muito longo
          ),
        ],
      ),
    );
  }
}
