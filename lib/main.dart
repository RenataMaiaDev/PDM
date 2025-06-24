// lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Para checar kDebugMode.
import 'package:spotfy/database/data/database_music.dart'; // Meu helper para o DB de músicas.
import 'package:spotfy/database/utils/data_seeder.dart'; // Minha função para popular o DB.

import 'routes/routes.dart'; // Minhas definições de rotas.

void main() async {
  // Garanto que o Flutter esteja pronto antes de tudo.
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseMusicHelper(); // Instancio meu helper de DB.
  final prefs = await SharedPreferences.getInstance(); // Pego as preferências do app.

  // Em MODO DEBUG, eu sempre limpo tudo para garantir um estado fresco.
  if (kDebugMode) {
    debugPrint('DEBUG: Limpando dados e forçando recriação do DB...');
    await prefs.setBool('hasSeededData', false); // Reseto o flag de populamento.
    await dbHelper.deleteDatabaseFile(); // Deletar o arquivo do DB.
    debugPrint('DEBUG: DB deletado. Será populado na próxima checagem.');
  }

  // Verifico se o DB já foi populado antes.
  final bool hasSeededData = prefs.getBool('hasSeededData') ?? false;

  if (!hasSeededData) {
    debugPrint('Populando o DB de músicas pela primeira vez...');
    await seedMusicData(); // Chamo minha função de populamento.
    await prefs.setBool('hasSeededData', true); // Marco como populado.
    debugPrint('DB populado e flag definido.');
  } else {
    debugPrint('DB já populado. Abrindo...');
    await dbHelper.database; // Apenas abro o banco de dados existente.
  }

  runApp(const MyApp()); // Inicio meu aplicativo.
}

/// O widget principal do meu app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tiro a faixa de "DEBUG".
      title: 'Meu Spotify Clone',
      theme: ThemeData.dark().copyWith( // Uso um tema escuro.
        scaffoldBackgroundColor: Colors.black, // Fundo preto.
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black, // AppBar preta.
          foregroundColor: Colors.white, // Ícones e texto brancos na AppBar.
        ),
      ),
      routes: Routes().listRoutes, // Minhas rotas nomeadas.
      initialRoute: '/', // Rota inicial.
    );
  }
}