// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:spotfy/pages/screen/user.dart';
import 'package:spotfy/database/utils/user_data_manager.dart';
import 'package:spotfy/database/utils/profile_notifier.dart';
import 'package:spotfy/pages/screen/home_page.dart'; // Importe a HomePage para navegação pós-logout

class AppDrawer extends StatefulWidget {
  final VoidCallback onProfileUpdated;

  const AppDrawer({super.key, required this.onProfileUpdated});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _userName;
  Uint8List? _userPhotoBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Escuta por mudanças no perfil e recarrega os dados do drawer
    profileNotifier.addListener(_loadUserData);
  }

  @override
  void dispose() {
    // É crucial remover o listener para evitar vazamentos de memória
    profileNotifier.removeListener(_loadUserData);
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final name = await UserDataManager.getUserName();
    final photo = await UserDataManager.getUserPhoto();
    if (mounted) {
      setState(() {
        _userName = name;
        _userPhotoBytes = photo;
      });
    }
  }

  // Função para lidar com o logout
  Future<void> _logout() async {
    await UserDataManager.clearUserData(); // Limpa os dados do usuário
    profileNotifier.notifyProfileUpdate(); // Notifica que o perfil foi "limpo"

    // Fecha o drawer antes de navegar
    if (mounted) { // Garante que o widget ainda está na árvore antes de manipular o Navigator
      Navigator.of(context).pop();
    }

    // *** IMPORTANTE: NAVEGAÇÃO DE LOGOUT ***
    // Esta linha remove todas as rotas da pilha e empurra a HomePage limpa.
    // Se você tiver uma tela de login específica, substitua 'HomePage' pela sua 'LoginPage'.
    // Ex: Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(builder: (context) => LoginPage()),
    //   (Route<dynamic> route) => false,
    // );
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()), // Volta para a HomePage limpa
        (Route<dynamic> route) => false, // Remove todas as rotas anteriores
      );
    }
    // O callback 'onProfileUpdated' para a HomePage é mais para fins de notificação adicional,
    // mas a navegação acima já garante o "reset" visual.
    // widget.onProfileUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[800],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[700],
                  backgroundImage: _userPhotoBytes != null
                      ? MemoryImage(_userPhotoBytes!)
                      : null,
                  child: _userPhotoBytes == null
                      ? const Icon(Icons.person, color: Colors.white, size: 50)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  _userName ?? 'Usuário Spotify', // Nome do usuário ou padrão
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle, color: Colors.white70),
            title: const Text('Meu Perfil', style: TextStyle(color: Colors.white)),
            onTap: () async {
              Navigator.of(context).pop(); // Fecha o drawer
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserPage(isCadastro: false)),
              );
              // Notifique que o perfil foi atualizado ao voltar da UserPage
              profileNotifier.notifyProfileUpdate();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white70),
            title: const Text('Sair', style: TextStyle(color: Colors.white)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}