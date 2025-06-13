import 'package:flutter/material.dart';
import 'package:spotfy/pages/screen/user.dart';

// Importa as páginas usadas nas rotas
import '../pages/screen/home_page.dart';
import '../pages/screen/login.dart';
import '../pages/screen/welcome.dart';
import '../pages/screen/splash_screen.dart';

// Classe responsável por definir as rotas da aplicação
class Routes {
  // Define a rota inicial (página de boas-vindas)
  String splash = '/';

  // Mapa que contém as rotas e suas respectivas telas (widgets)
  Map<String, Widget Function(BuildContext)> listRoutes = {
    '/': (context) =>
        const SplashScreen(), // Rota inicial → tela de carregamento
    '/welcome': (context) => const Welcome(), // Rota inicial → tela Welcome
    '/login': (context) => const Login(), // Rota para a tela de Login
    '/home': (context) => const HomePage(), // Rota para a tela principal (Home)
    '/user': (context) => const UserPage(), // Rota para a tela de cadastro de usuário
  };
}
