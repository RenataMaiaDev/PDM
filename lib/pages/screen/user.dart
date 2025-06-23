import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotfy/database/models/user_model.dart';
import 'package:spotfy/database/repositories/user_repository.dart';
import 'package:spotfy/database/utils/profile_notifier.dart';

class UserPage extends StatefulWidget {
  // Define se a tela é para cadastro (true) ou edição de perfil (false)
  final bool isCadastro;

  const UserPage({super.key, this.isCadastro = true});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // Key para controlar o formulário e validar os campos
  final _formKey = GlobalKey<FormState>();

  // Controllers para os campos de texto do formulário
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  // Armazeno a foto do usuário em bytes para mostrar e salvar
  Uint8List? _fotoBytes;

  // Lista de câmeras disponíveis no dispositivo, carregadas no initState
  List<CameraDescription>? _cameras;

  // Instância do ImagePicker para pegar imagens da galeria
  final ImagePicker _imagePicker = ImagePicker();

  // Flags para saber se o usuário está logado e seus dados
  bool _usuarioLogado = false;
  Usuario? _usuarioLogadoDados;

  // Repositório para acessar dados do usuário no banco
  final UsuarioRepository _repo = UsuarioRepository();

  @override
  void initState() {
    super.initState();
    // Inicializa a lista de câmeras do aparelho
    _initCameraList();

    // Se for tela de edição, carrego os dados do usuário logado para preencher o formulário
    if (!widget.isCadastro) {
      _carregarUsuarioLogado();
    } else {
      _usuarioLogado = false;
    }
  }

  // Método que busca as câmeras disponíveis no dispositivo e atualiza a UI
  Future<void> _initCameraList() async {
    try {
      _cameras = await availableCameras();
      setState(() {}); // Atualiza para poder usar as câmeras depois
    } catch (e) {
      debugPrint('Error loading cameras: $e');
    }
  }

  // Carrega os dados do usuário logado para edição do perfil
  Future<void> _carregarUsuarioLogado() async {
    final usuario = await _repo.getUsuarioLogado();

    if (usuario != null) {
      setState(() {
        _usuarioLogado = true;
        _usuarioLogadoDados = usuario;
        _nomeController.text = usuario.nome;
        _emailController.text = usuario.email;
        _fotoBytes = usuario.foto;
      });
    } else {
      setState(() {
        _usuarioLogado = false;
      });
    }
  }

  // Método para escolher imagem da galeria e atualizar a foto exibida
  Future<void> _pickFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600, // Limita o tamanho da imagem para otimizar memória
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _fotoBytes = bytes; // Atualizo foto para mostrar no avatar
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // Abre modal para escolher entre tirar foto ou escolher da galeria
  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900], // Fundo escuro para combinar com tema
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              // Opção para câmera: abre a tela customizada para tirar foto
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.of(context).pop(); // Fecha o modal
                  if (_cameras != null && _cameras!.isNotEmpty) {
                    // Navega para tela da câmera e espera receber bytes da foto
                    final bytes = await Navigator.of(context).push<Uint8List>(
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(cameras: _cameras!),
                      ),
                    );
                    if (bytes != null) {
                      setState(() {
                        _fotoBytes = bytes; // Atualiza foto com imagem tirada
                      });
                    }
                  } else {
                    // Caso não tenha câmera disponível, mostra mensagem
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Camera not available')),
                    );
                  }
                },
              ),
              // Opção para escolher imagem da galeria
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop(); // Fecha o modal
                  _pickFromGallery(); // Abre galeria para escolher imagem
                },
              ),
              // Cancelar para fechar o modal sem ação
              ListTile(
                leading: const Icon(Icons.close, color: Colors.white),
                title: const Text('Cancel', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  // Método para salvar ou atualizar usuário conforme modo da tela
  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      // Se for edição e usuário não digitou nova senha, mantém a antiga
      final senhaParaSalvar = widget.isCadastro || _senhaController.text.isNotEmpty
          ? _senhaController.text
          : _usuarioLogadoDados?.senha ?? '';

      // Cria objeto Usuario com dados do formulário
      final usuario = Usuario(
        id: _usuarioLogadoDados?.id,
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: senhaParaSalvar,
        foto: _fotoBytes,
      );

      try {
        if (!widget.isCadastro && _usuarioLogado) {
          // Atualiza perfil do usuário no banco de dados
          await _repo.atualizar(usuario);
          // Mostra mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
          // >>> Chame o notificador de perfil aqui <<<
          profileNotifier.notifyProfileUpdate();
        } else {
          // Insere novo usuário no banco de dados
          await _repo.inserir(usuario);
          // Mensagem de sucesso para cadastro
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User registered successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
          // Reseta o formulário e limpa foto após cadastro
          _formKey.currentState!.reset();
          setState(() {
            _fotoBytes = null;
          });
          // >>> Chame o notificador de perfil aqui após um novo cadastro,
          // caso o usuário seja logado automaticamente e a Home precise exibir o novo perfil.
          // Isso é opcional e depende da sua lógica de login/cadastro.
          profileNotifier.notifyProfileUpdate();
        }
        // Se a tela não for de cadastro, navega de volta após salvar.
        // Se for cadastro, a lógica de navegação deve ser tratada em outro lugar (ex: tela de login).
        if (!widget.isCadastro) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        debugPrint('Error saving user: $e');
        // Mensagem de erro caso algo falhe
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving user. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Sempre libero os controllers para evitar vazamento de memória
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // Decoração padrão para os campos de texto, tema escuro com cantos arredondados
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  // Validador simples para email, com regex básica
  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Validador para senha: obrigatório no cadastro, opcional na edição (mas se preencher deve ter 6+ chars)
  String? _senhaValidator(String? value) {
    if (widget.isCadastro) {
      if (value == null || value.isEmpty) {
        return 'Please enter your password';
      }
      if (value.length < 6) {
        return 'Password must be at least 6 characters long';
      }
    } else {
      if (value != null && value.isNotEmpty && value.length < 6) {
        return 'Password must be at least 6 characters long';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo escuro para combinar com tema geral
      appBar: AppBar(
        title: Text(widget.isCadastro ? 'Cadastrar Usuário' : 'Editar Perfil'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white), // Para o botão de voltar
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Avatar clicável para escolher foto: mostra ícone ou imagem selecionada
                  GestureDetector(
                    onTap: _showImageSourceActionSheet,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.grey[800],
                      child: _fotoBytes == null
                          ? const Icon(Icons.camera_alt, size: 70, color: Colors.white)
                          : ClipOval(
                              child: Image.memory(
                                _fotoBytes!,
                                width: 160,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Campo nome com validação básica
                  TextFormField(
                    controller: _nomeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 20),
                  // Campo email com validação mais robusta
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Email'),
                    validator: _emailValidator,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  // Campo senha aparece diferente no cadastro e na edição
                  if (widget.isCadastro)
                    TextFormField(
                      controller: _senhaController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Password'),
                      validator: _senhaValidator,
                    ),
                  if (widget.isCadastro)
                    const SizedBox(height: 30)
                  else
                    const SizedBox(height: 20),
                  // Botão que chama a função de salvar ou editar
                  ElevatedButton(
                    onPressed: _salvar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF05D853),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      widget.isCadastro ? 'Salvar' : 'Editar',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
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

// A classe CameraScreen permanece inalterada pois ela apenas captura a imagem
// e a retorna em bytes, não interagindo diretamente com os dados do perfil.
class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({required this.cameras, super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isTakingPicture = false;

  late CameraDescription _selectedCamera;

  @override
  void initState() {
    super.initState();
    _selectedCamera = widget.cameras.first;
    _initCamera(_selectedCamera);
  }

  Future<void> _initCamera(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
    }
    _controller = CameraController(camera, ResolutionPreset.medium);
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _selectedCamera = camera;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_isInitialized || _isTakingPicture || _controller == null) return;

    setState(() {
      _isTakingPicture = true;
    });

    try {
      final XFile picture = await _controller!.takePicture();
      final bytes = await picture.readAsBytes();
      if (mounted) {
        Navigator.of(context).pop(bytes);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  List<DropdownMenuItem<CameraDescription>> get _cameraDropdownItems {
    return widget.cameras
        .map(
          (camera) => DropdownMenuItem(
            value: camera,
            child: Text(
              camera.lensDirection.name.toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Take Picture'),
        backgroundColor: Colors.black,
        actions: [
          if (widget.cameras.length > 1)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: DropdownButton<CameraDescription>(
                dropdownColor: Colors.grey[900],
                value: _selectedCamera,
                items: _cameraDropdownItems,
                onChanged: (camera) {
                  if (camera != null) {
                    _initCamera(camera);
                  }
                },
                underline: const SizedBox(),
                iconEnabledColor: Colors.white,
              ),
            ),
        ],
      ),
      body: _isInitialized && _controller != null
          ? Stack(
              children: [
                CameraPreview(_controller!),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton(
                      backgroundColor: const Color(0xFF05D853),
                      shape: const CircleBorder(),
                      onPressed: _takePicture,
                      child: _isTakingPicture
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}