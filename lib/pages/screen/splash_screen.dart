import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Aguardo 3 segundos e navego automaticamente para a tela de boas-vindas ('/welcome')
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto para combinar com o tema escuro do app
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo do app que fica no centro da splash
            Image.asset('assets/image/download.png', width: 120, height: 120),
            const SizedBox(height: 20),
            // Texto "Spotify" com fonte grande, negrito e cor verde característica do app
            const Text(
              'Spotify',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1DB954),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
