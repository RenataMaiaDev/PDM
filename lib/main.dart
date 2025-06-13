import 'package:flutter/material.dart';
// import 'pages/home_page.dart'; // Comentado, pois as rotas já importam a HomePage corretamente
import 'routes/routes.dart'; // Importa as rotas do app, definidas no arquivo routes.dart

void main() {
  runApp(MyApp()); // Executa o app chamando o widget MyApp
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove o banner "debug" que aparece no canto da tela
      title: 'Meu Spotify Clone',        // Título do app
      theme: ThemeData.dark(),            // Define tema escuro padrão para todo o app
      routes: Routes().listRoutes,        // Passa as rotas definidas na classe Routes para navegação
      initialRoute: '/',                  // Rota inicial ao abrir o app, aqui é a tela de boas-vindas
    );
  }
}

