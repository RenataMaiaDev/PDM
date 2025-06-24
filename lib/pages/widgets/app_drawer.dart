import 'package:flutter/material.dart';
import 'dart:typed_data'; 
import 'package:spotfy/pages/screen/user.dart'; 
import 'package:spotfy/database/utils/user_data_manager.dart'; 
import 'package:spotfy/database/utils/profile_notifier.dart'; 
import 'package:spotfy/pages/screen/login.dart';

/// Este é o [AppDrawer], o menu lateral do meu aplicativo.
/// Ele mostra o perfil do usuário logado e opções de navegação.
class AppDrawer extends StatefulWidget {
  // Recebo um callback para notificar a tela principal sobre atualizações no perfil.
  final VoidCallback onProfileUpdated;

  const AppDrawer({super.key, required this.onProfileUpdated});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

/// O estado do [AppDrawer], onde eu gerencio as informações do perfil.
class _AppDrawerState extends State<AppDrawer> {
  // Armazeno o nome e os bytes da foto do usuário logado.
  String? _userName;
  Uint8List? _userPhotoBytes;

  @override
  void initState() {
    super.initState();
    // Assim que o drawer é inicializado, eu carrego os dados do usuário.
    _loadUserData();
    // Eu adiciono um listener ao [profileNotifier] para atualizar o drawer
    // sempre que o perfil do usuário for alterado ou ao fazer logout.
    profileNotifier.addListener(_loadUserData);
  }

  @override
  void dispose() {
    // É muito importante remover o listener quando o widget é descartado
    // para evitar vazamentos de memória.
    profileNotifier.removeListener(_loadUserData);
    super.dispose();
  }

  /// Esta função é responsável por carregar o nome e a foto do usuário
  /// usando o [UserDataManager]. Eu atualizo o estado do widget quando os dados chegam.
  Future<void> _loadUserData() async {
    final name = await UserDataManager.getUserName();
    final photo = await UserDataManager.getUserPhoto();
    if (mounted) { // Verifico se o widget ainda está ativo antes de atualizar a UI.
      setState(() {
        _userName = name;
        _userPhotoBytes = photo;
      });
    }
  }

  /// Esta é a função que eu chamo quando o usuário clica em "Sair".
  /// Ela simula um "logout" limpando a sessão no lado do cliente.
  Future<void> _logout() async {
    // Primeiro, eu limpo os dados do usuário do SharedPreferences usando meu [UserDataManager].
    // É importante notar que isso não apaga o usuário do banco de dados SQLite, apenas
    // remove a indicação de que ele está logado na sessão atual do app.
    await UserDataManager.clearUserData();
    // Depois, eu notifico o [profileNotifier] para que o avatar e outros widgets
    // que dependem do perfil saibam que ele foi "limpo" e atualizem sua exibição.
    profileNotifier.notifyProfileUpdate();

    // Eu fecho o drawer antes de iniciar a navegação para a tela de login.
    if (mounted) {
      Navigator.of(context).pop();
    }

    // *** NAVEGAÇÃO CRÍTICA DE LOGOUT ***
    // Esta parte é crucial. Eu removo *todas* as rotas da pilha de navegação
    // e empurro a [LoginPage] como a nova rota inicial. Isso garante que o usuário
    // não consiga voltar para a tela principal (ou outras telas que exigem login)
    // usando o botão de voltar após o logout.
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Login()), // Redireciono para a tela de Login.
        (Route<dynamic> route) => false, // Removo todas as rotas anteriores.
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900], // Fundo escuro para o drawer.
      child: ListView(
        padding: EdgeInsets.zero, // Removo o padding padrão do ListView para o DrawerHeader.
        children: <Widget>[
          // O cabeçalho do meu drawer, mostrando o avatar e o nome do usuário.
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[800], // Cor de fundo do cabeçalho.
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[700],
                  // Se eu tiver uma foto, eu a exibo; caso contrário, mostro um ícone padrão.
                  backgroundImage: _userPhotoBytes != null
                      ? MemoryImage(_userPhotoBytes!)
                      : null,
                  child: _userPhotoBytes == null
                      ? const Icon(Icons.person, color: Colors.white, size: 50)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  _userName ?? 'Usuário Spotify', // Mostro o nome do usuário ou um padrão.
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Opção para ir para a tela "Meu Perfil" (edição).
          ListTile(
            leading: const Icon(Icons.account_circle, color: Colors.white70),
            title: const Text('Meu Perfil', style: TextStyle(color: Colors.white)),
            onTap: () async {
              Navigator.of(context).pop(); // Fecho o drawer antes de navegar.
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserPage(isCadastro: false)),
              );
              // Ao retornar da tela de perfil, eu notifico para que as mudanças apareçam.
              profileNotifier.notifyProfileUpdate();
            },
          ),
          // Opção para fazer logout.
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white70),
            title: const Text('Sair', style: TextStyle(color: Colors.white)),
            onTap: _logout, // Chama minha função de logout.
          ),
        ],
      ),
    );
  }
}