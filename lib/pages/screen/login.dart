import 'package:flutter/material.dart';
import 'package:spotfy/database/repositories/user_repository.dart';
import 'package:spotfy/database/utils/user_data_manager.dart'; 
import 'package:spotfy/database/utils/profile_notifier.dart';
import 'package:spotfy/pages/screen/user.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Chave do formulário para validação
  final _formKey = GlobalKey<FormState>();
  // Controllers para capturar texto dos campos
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Função para tentar fazer login quando o usuário clicar no botão
  void _tryLogin() async {
    if (_formKey.currentState!.validate()) {
      final repo = UsuarioRepository();
      final email = _emailController.text.trim();
      final senha = _passwordController.text.trim();

      // Chamo o método login do repositório para validar credenciais
      final usuario = await repo.login(email, senha);

      if (usuario != null) {
        // --- INÍCIO DAS MODIFICAÇÕES ---
        // 1. Salva os dados do usuário logado no UserDataManager
        await UserDataManager.saveUserName(usuario.nome);
        await UserDataManager.saveUserPhoto(usuario.foto);

        // 2. Notifica o ProfileNotifier para que os widgets que dependem do perfil
        // (como UserAvatar e AppDrawer) possam se atualizar automaticamente.
        profileNotifier.notifyProfileUpdate();

        // Login OK, navego para a página principal, substituindo essa
        // Certifique-se de que '/home' está configurado nas rotas do seu MaterialApp
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Login falhou, mostro mensagem de erro para o usuário
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email ou senha incorretos')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _formKey.currentState?.dispose(); // Dispor o GlobalKey também
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto para tema escuro
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey, // Passo a chave para o formulário validar
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo da aplicação no topo
                  Image.asset(
                    'assets/image/logo.jpg',
                    height: 90,
                  ),
                  const SizedBox(height: 70),
                  // Campo de email com validação de formato e preenchimento
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Email address",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegExp = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                      if (!emailRegExp.hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress, // Teclado otimizado para email
                  ),
                  const SizedBox(height: 20),
                  // Campo de senha com validação mínima e ocultação do texto
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Botão para realizar o login, estilizado com cor e bordas arredondadas
                  ElevatedButton(
                    onPressed: _tryLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF05D853),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "LOG IN",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Texto separador para opções alternativas de login
                  const Text(
                    "or continue with",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  // Ícones para login com Facebook ou Apple (ainda sem funcionalidade)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.facebook, color: Colors.blue, size: 46),
                      SizedBox(width: 10),
                      Icon(Icons.apple, color: Colors.white, size: 46),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Botão para navegar para a tela de cadastro
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserPage(isCadastro: true)),
                      );
                    },
                    child: const Text(
                      "Não tem uma conta? Cadastre-se!",
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline, // Adicionei sublinhado para parecer mais um link
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Texto para link "Esqueceu sua senha?" (sem interação ainda)
                  const Text(
                    "Forgot your password?",
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}