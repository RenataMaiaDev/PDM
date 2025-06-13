import 'package:flutter/material.dart';

// Widget genérico para representar cards
class SectionWidget extends StatelessWidget {
  // Título da seção (ex: "Artistas Favoritos", "Playlists", etc)
  final String title;

  // Lista de widgets que serão exibidos na lista horizontal (normalmente cards)
  final List<Widget> cards;

  const SectionWidget({
    super.key,
    required this.title,  // título obrigatório
    required this.cards,  // lista de widgets obrigatória
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinha o conteúdo da coluna à esquerda
      children: [
        // Espaçamento interno para o título, com padding horizontal e vertical
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title, // Texto do título da seção
            style: const TextStyle(
              fontSize: 20,          // Tamanho da fonte do título
              fontWeight: FontWeight.bold, // Título em negrito para destaque
            ),
          ),
        ),

        // Espaço destinado para a lista horizontal de cards
        SizedBox(
          height: 150, // Altura fixa para a lista de cards (ajustável)
          child: ListView(
            scrollDirection: Axis.horizontal, // Rolagem horizontal
            children: cards,                   // Recebe os cards passados via parâmetro
          ),
        ),
      ],
    );
  }
}
