// lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Importante para usar kDebugMode
import 'package:spotfy/database/data/database_music.dart'; // Importe o seu DatabaseMusicHelper
import 'package:spotfy/database/utils/data_seeder.dart';

import 'routes/routes.dart'; // Importa as rotas do app

void main() async {
  // Garante que os bindings do Flutter estejam inicializados.
  // Isso é essencial antes de usar plugins como sqflite.
  WidgetsFlutterBinding.ensureInitialized();

  // --- Lógica de inicialização e populamento do banco de dados ---
  final dbHelper = DatabaseMusicHelper(); // Instância do seu helper de DB
  final prefs = await SharedPreferences.getInstance();

  // ATENÇÃO: Esta lógica de limpeza será executada APENAS em MODO DEBUG.
  // Isso força a recriação do DB e repopulamento a cada 'flutter run'.
  if (kDebugMode) {
    debugPrint('MODO DEBUG: Limpando SharedPreferences e forçando repopulação do banco de dados...');
    // Reseta o flag 'hasSeededData' para false, para que o seeder seja executado.
    await prefs.setBool('hasSeededData', false);
    // Deleta o arquivo físico do banco de dados para garantir uma recriação completa.
    await dbHelper.deleteDatabaseFile();
    debugPrint('MODO DEBUG: Arquivo do banco de dados deletado. Seeding será forçado na próxima checagem.');
  }
  // --- Fim da lógica específica de debug ---

  // Agora, verifica o flag 'hasSeededData' (que pode ter sido resetado em debug)
  final bool hasSeededData = prefs.getBool('hasSeededData') ?? false;

  if (!hasSeededData) {
    debugPrint('Primeira execução (ou forçada em debug): Populando o banco de dados de músicas...');
    // Chama a função para inserir os dados iniciais
    await seedMusicData();
    // Define o flag para true, indicando que o seeding foi feito
    await prefs.setBool('hasSeededData', true);
    debugPrint('Banco de dados de músicas populado e flag definido.');
  } else {
    debugPrint('Banco de dados de músicas já foi populado. Nenhuma ação necessária.');
    // Garante que o banco de dados seja aberto mesmo se já estiver populado.
    await dbHelper.database;
  }

  runApp(const MyApp()); // Executa o app chamando o widget MyApp
}

class MyApp extends StatelessWidget {
  // Adicionado 'const' e 'Key' para boas práticas de construtores Flutter.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove o banner de "DEBUG"
      title: 'Meu Spotify Clone',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black, // Fundo principal da maioria das telas
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black, // Cor da AppBar
          foregroundColor: Colors.white, // Cor dos ícones e texto na AppBar
        ),
      ),
      routes: Routes().listRoutes,
      initialRoute: '/',
    );
  }
}