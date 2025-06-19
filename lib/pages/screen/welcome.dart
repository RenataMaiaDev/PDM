import 'package:flutter/material.dart';
import 'package:spotfy/pages/screen/user.dart';

// Tela inicial de boas-vindas do app, sem estado porque é uma tela simples, só mostra opções
class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto para combinar com o tema escuro do app
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32), // Espaçamento lateral para deixar os elementos alinhados e confortáveis
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centralizo verticalmente todo o conteúdo da tela
              children: [
                // Logo do app no topo centralizado, com altura fixa para manter proporção
                Image.asset(
                  'assets/image/logo.jpg', 
                  height: 90,
                ),

                const SizedBox(height: 30), // Espaço entre o logo e o texto principal

                // Mensagem de boas-vindas com quebra de linha para ficar mais impactante e clara
                const Text(
                  "We play the music.\nYou enjoy it. Deal?", // Mensagem direta e descontraída
                  textAlign: TextAlign.center, // Centraliza o texto para ficar mais harmônico
                  style: TextStyle(
                    color: Colors.white,       // Cor branca para contraste no fundo preto
                    fontSize: 34,              // Fonte grande para chamar atenção
                    fontWeight: FontWeight.bold, // Negrito para dar ênfase
                  ),
                ),

                const SizedBox(height: 40), // Espaço para separar o texto dos botões

                // Botão principal “SIGN UP” com cor verde característica do Spotify
                ElevatedButton(
                  onPressed: () {
                    // Navega para a tela de cadastro, passando que está no modo cadastro
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserPage(isCadastro: true),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF05D853), // Verde Spotify
                    minimumSize: const Size(double.infinity, 50), // Botão ocupa toda a largura possível e altura confortável
                  ),
                  child: const Text(
                    "SIGN UP",
                    style: TextStyle(color: Colors.white), // Texto branco para contraste
                  ),
                ),

                const SizedBox(height: 20), // Espaço entre os botões

                // Botão “LOG IN” com estilo de borda branca (OutlinedButton)
                OutlinedButton(
                  onPressed: () {
                    // Navega para a tela de login usando rota nomeada
                    Navigator.pushNamed(context, '/login');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white, // Cor do texto branco
                    side: const BorderSide(color: Colors.white), // Borda branca para destacar botão no fundo preto
                    minimumSize: const Size(double.infinity, 50), // Mesma largura e altura do botão acima para consistência visual
                  ),
                  child: const Text("LOG IN"),
                ),

                const SizedBox(height: 90), // Espaço grande antes do texto final, dando respiro na interface

                // Texto com aviso dos termos de uso, fonte menor e cor branca com opacidade para não roubar atenção
                const Text(
                  "By clicking on Sign up, you agree to \nSpotify's Terms and Conditions of Use.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center, // Centralizado para ficar alinhado com o resto da tela
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
