import 'package:flutter/material.dart';

// Tela inicial de boas-vindas (sem estado, pois não precisa de controle interno)
class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Define o fundo da tela como preto
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32), // Espaçamento lateral
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centraliza os elementos verticalmente
              children: [
                // Logo do aplicativo
                Image.asset(
                  'assets/image/logo.jpg', 
                  height: 90,
                ),

                const SizedBox(height: 30), // Espaço entre o logo e o texto

                // Mensagem principal da tela
                const Text(
                  "We play the music.\nYou enjoy it. Deal?", // Texto com quebra de linha
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,       // Cor branca
                    fontSize: 34,              // Tamanho da fonte
                    fontWeight: FontWeight.bold, // Negrito
                  ),
                ),

                const SizedBox(height: 40),

                // Botão de "SIGN UP"
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/user'); // Redireciona para a tela de login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF05D853), // Cor verde (estilo Spotify)
                    minimumSize: const Size(double.infinity, 50), // Ocupa a largura total
                  ),
                  child: const Text(
                    "SIGN UP",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20),

                // Botão de "LOG IN" com borda (OutlinedButton)
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login'); // Também leva ao login
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white, // Cor do texto
                    side: const BorderSide(color: Colors.white), // Borda branca
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("LOG IN"),
                ),

                const SizedBox(height: 90), 

                // Texto com os termos de uso
                const Text(
                  "By clicking on Sign up, you agree to \nSpotify's Terms and Conditions of Use.",
                  style: TextStyle(
                    color: Colors.white70, // Cinza claro
                    fontSize: 12,          // Fonte pequena
                  ),
                  textAlign: TextAlign.center, // Centraliza o texto
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
