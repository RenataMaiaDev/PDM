import 'dart:typed_data'; 
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotfy/database/models/user_model.dart';
import 'package:spotfy/database/repositories/user_repository.dart';
import 'package:spotfy/database/utils/profile_notifier.dart';
import 'package:spotfy/database/utils/user_data_manager.dart';


class UserPage extends StatefulWidget {
  final bool isCadastro;

  const UserPage({super.key, this.isCadastro = true});

  @override
  State<UserPage> createState() => _UserPageState();
}

// O estado da [UserPage], onde eu gerencio todo o fluxo de dados e UI.
class _UserPageState extends State<UserPage> {
  // A chave que eu uso para validar meu formulário.
  final _formKey = GlobalKey<FormState>();

  // Meus controladores para os campos de texto.
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  // Aqui eu guardo os bytes da foto de perfil, para exibir e salvar.
  Uint8List? _fotoBytes;

  // Uma lista das câmeras que meu aparelho tem, que eu carrego ao iniciar.
  List<CameraDescription>? _cameras;

  // Meu objeto para facilitar a escolha de imagens da galaria.
  final ImagePicker _imagePicker = ImagePicker();

  // Flags para controlar o estado do usuário (logado ou não) e seus dados.
  bool _usuarioLogado = false;
  Usuario? _usuarioLogadoDados;

  // O repositório que eu uso para interagir com os dados do usuário no banco.
  final UsuarioRepository _repo = UsuarioRepository();

  @override
  void initState() {
    super.initState();
    // Eu começo inicializando a lista de câmeras disponíveis.
    _initCameraList();

    // Se eu estiver no modo de edição (não é cadastro), eu carrego os dados do usuário.
    if (!widget.isCadastro) {
      _carregarUsuarioLogado();
    } else {
      // Se for cadastro, assumo que não há usuário logado para preencher.
      _usuarioLogado = false;
    }
  }

  // Eu busco as câmeras disponíveis no dispositivo e atualizo a UI.
  Future<void> _initCameraList() async {
    try {
      _cameras = await availableCameras();
      setState(() {}); // Atualizo o estado para que eu possa usar as câmeras.
    } catch (e) {
      debugPrint('Error loading cameras: $e'); // Se der erro, eu registro.
    }
  }

  // Minha função para carregar os dados do usuário logado, caso eu esteja editando o perfil.
  // Eu preencho os campos do formulário e a foto com os dados existentes.
  Future<void> _carregarUsuarioLogado() async {
    final usuario = await _repo.getUsuarioLogado(); // Busco o usuário logado no meu repositório.

    if (usuario != null) {
      setState(() {
        _usuarioLogado = true;
        _usuarioLogadoDados = usuario;
        _nomeController.text = usuario.nome;
        _emailController.text = usuario.email;
        _fotoBytes = usuario.foto;
      });
      // **IMPORTANTE:** Eu garanto que o [UserDataManager] esteja atualizado com os dados do banco.
      // Isso é essencial para que o avatar na [HomePage] e no [AppDrawer] mostre o perfil correto
      // mesmo que eu não tenha feito nenhuma alteração nesta tela.
      await UserDataManager.saveUserName(usuario.nome);
      await UserDataManager.saveUserPhoto(usuario.foto);
    } else {
      setState(() {
        _usuarioLogado = false;
      });
    }
  }

  // Este método permite que eu escolha uma imagem da galeria.
  // A imagem selecionada será usada para o avatar.
  Future<void> _pickFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600, // Limito o tamanho para otimizar.
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _fotoBytes = bytes; // Atualizo a foto exibida na tela.
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // Eu mostro um modal para o usuário escolher se quer tirar uma foto ou pegar da galeria.
  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900], // Fundo escuro.
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              // Opção para tirar foto com a câmera.
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.of(context).pop(); // Fecho o modal.
                  if (_cameras != null && _cameras!.isNotEmpty) {
                    // Eu navego para a tela da câmera e espero o resultado (bytes da foto).
                    final bytes = await Navigator.of(context).push<Uint8List>(
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(cameras: _cameras!),
                      ),
                    );
                    if (bytes != null) {
                      setState(() {
                        _fotoBytes = bytes; // Atualizo a foto com a imagem que tirei.
                      });
                    }
                  } else {
                    // Se não tiver câmera, eu aviso.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Camera not available')),
                    );
                  }
                },
              ),
              // Opção para escolher da galeria.
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop(); // Fecho o modal.
                  _pickFromGallery(); // Chamo minha função para abrir a galeria.
                },
              ),
              // Opção para cancelar e fechar o modal.
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

  // Minha função para salvar (cadastrar) ou atualizar (editar) os dados do usuário.
  // Eu valido o formulário e depois faço a operação no banco de dados.
  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) { // Se o formulário for válido...
      // Defino qual senha vou salvar: a nova digitada ou a antiga se não mudei.
      final senhaParaSalvar = widget.isCadastro || _senhaController.text.isNotEmpty
          ? _senhaController.text
          : _usuarioLogadoDados?.senha ?? '';

      // Crio um objeto [Usuario] com os dados do formulário.
      final usuario = Usuario(
        id: _usuarioLogadoDados?.id, // Uso o ID existente se for edição.
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: senhaParaSalvar,
        foto: _fotoBytes,
      );

      try {
        if (!widget.isCadastro && _usuarioLogado) {
          // Se for edição de perfil, eu atualizo o usuário.
          await _repo.atualizar(usuario);
          // **IMPORTANTE:** Eu atualizo o [UserDataManager] depois de salvar.
          // Isso faz com que o avatar na [HomePage] e no [Drawer] reflita as mudanças imediatamente.
          await UserDataManager.saveUserName(usuario.nome);
          await UserDataManager.saveUserPhoto(usuario.foto);

          // Mostro uma mensagem de sucesso.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
          // Notifico quem está escutando que o perfil mudou.
          profileNotifier.notifyProfileUpdate();
        } else {
          // Se for cadastro, eu insiro um novo usuário.
          await _repo.inserir(usuario);
          // **IMPORTANTE:** Aqui também eu atualizo o [UserDataManager] após um novo cadastro.
          // Se eu estiver "logando" o usuário automaticamente após o registro,
          // isso garante que a [HomePage] já mostre o perfil certo.
          await UserDataManager.saveUserName(usuario.nome);
          await UserDataManager.saveUserPhoto(usuario.foto);

          // Mensagem de sucesso para o cadastro.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User registered successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
          // Eu limpo o formulário e a foto para um novo cadastro.
          _formKey.currentState!.reset();
          setState(() {
            _fotoBytes = null;
          });
          // Notifico quem está escutando que um novo perfil foi criado/atualizado.
          profileNotifier.notifyProfileUpdate();
        }
        // Se eu estiver editando, eu volto para a tela anterior.
        if (!widget.isCadastro) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        debugPrint('Error saving user: $e');
        // Se algo der errado, eu mostro uma mensagem de erro.
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
    // Sempre libero os recursos dos meus controladores para evitar vazamentos.
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // Minha função para padronizar a aparência dos campos de texto.
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

  // Meu validador para o campo de email.
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

  // Meu validador para a senha: obrigatório no cadastro, opcional na edição.
  String? _senhaValidator(String? value) {
    if (widget.isCadastro) { // Se for cadastro...
      if (value == null || value.isEmpty) {
        return 'Please enter your password';
      }
      if (value.length < 6) {
        return 'Password must be at least 6 characters long';
      }
    } else { // Se for edição...
      if (value != null && value.isNotEmpty && value.length < 6) {
        return 'Password must be at least 6 characters long';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo escuro para a tela.
      appBar: AppBar(
        title: Text(widget.isCadastro ? 'Cadastrar Usuário' : 'Editar Perfil'), // Título dinâmico.
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white), // Ícone de voltar branco.
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey, // Associo a chave ao formulário.
              child: ListView( // Uso um ListView para que a tela seja rolhável.
                shrinkWrap: true,
                children: [
                  // Meu avatar clicável para escolher a foto.
                  GestureDetector(
                    onTap: _showImageSourceActionSheet, // Chama o modal de opções.
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.grey[800],
                      child: _fotoBytes == null // Se não tem foto, mostra um ícone.
                          ? const Icon(Icons.camera_alt, size: 70, color: Colors.white)
                          : ClipOval( // Se tem foto, mostra a imagem arredondada.
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
                  // Campo para o nome.
                  TextFormField(
                    controller: _nomeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 20),
                  // Campo para o email.
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Email'),
                    validator: _emailValidator, // Uso meu validador de email.
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  // Campo para a senha, aparece só no cadastro ou se for edição e eu quiser mudar.
                  if (widget.isCadastro) // Só mostro o campo de senha completo no cadastro.
                    TextFormField(
                      controller: _senhaController,
                      obscureText: true, // Para esconder a senha.
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Password'),
                      validator: _senhaValidator, // Uso meu validador de senha.
                    ),
                  if (widget.isCadastro)
                    const SizedBox(height: 30) // Espaçamento diferente entre cadastro e edição.
                  else
                    const SizedBox(height: 20),
                  // O botão de "Salvar" ou "Editar".
                  ElevatedButton(
                    onPressed: _salvar, // Chama minha função de salvar/editar.
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF05D853), // Cor verde do Spotify.
                      minimumSize: const Size(double.infinity, 50), // Botão de largura total.
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Botão arredondado.
                      ),
                    ),
                    child: Text(
                      widget.isCadastro ? 'Salvar' : 'Editar', // Texto dinâmico.
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

// Esta é a tela da câmera que eu uso para tirar fotos para o perfil.
class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras; // Recebo as câmeras disponíveis.

  const CameraScreen({required this.cameras, super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

// O estado da [CameraScreen], onde eu controlo a visualização da câmera e a captura de fotos.
class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller; // Meu controlador da câmera.
  bool _isInitialized = false; // Flag para saber se a câmera está pronta.
  bool _isTakingPicture = false; // Flag para evitar múltiplas capturas.

  late CameraDescription _selectedCamera; // A câmera que eu estou usando no momento.

  @override
  void initState() {
    super.initState();
    _selectedCamera = widget.cameras.first; // Começo usando a primeira câmera disponível.
    _initCamera(_selectedCamera); // Inicio a câmera selecionada.
  }

  // Eu inicializo o controlador da câmera com a [camera] especificada.
  // Se já houver um controlador, eu o descarto antes de criar um novo.
  Future<void> _initCamera(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose(); // Libero o controlador anterior.
    }
    _controller = CameraController(camera, ResolutionPreset.medium); // Crio um novo controlador.
    try {
      await _controller!.initialize(); // Tento inicializar a câmera.
      if (mounted) { // Verifico se o widget ainda está na árvore.
        setState(() {
          _isInitialized = true; // Marco como inicializada.
          _selectedCamera = camera; // Atualizo a câmera selecionada.
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e'); // Se algo der errado, eu registro.
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // Eu sempre descarto o controlador da câmera quando a tela é fechada.
    super.dispose();
  }

  // Minha função para tirar a foto.
  // Eu mostro um indicador de carregamento enquanto a foto é processada.
  Future<void> _takePicture() async {
    if (!_isInitialized || _isTakingPicture || _controller == null) return; // Só continuo se a câmera estiver pronta.

    setState(() {
      _isTakingPicture = true; // Ativo o indicador de "tirando foto".
    });

    try {
      final XFile picture = await _controller!.takePicture(); // Tiro a foto.
      final bytes = await picture.readAsBytes(); // Converso a foto para bytes.
      if (mounted) {
        Navigator.of(context).pop(bytes); // Retorno os bytes da foto para a tela anterior.
      }
    } catch (e) {
      debugPrint('Error taking picture: $e'); // Se der erro ao tirar a foto.
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false; // Desativo o indicador.
        });
      }
    }
  }

  // Eu crio os itens para o dropdown de seleção de câmera.
  List<DropdownMenuItem<CameraDescription>> get _cameraDropdownItems {
    return widget.cameras
        .map(
          (camera) => DropdownMenuItem(
            value: camera,
            child: Text(
              camera.lensDirection.name.toUpperCase(), // Exibo a direção da lente (FRONT/BACK).
              style: const TextStyle(color: Colors.white),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto para a tela da câmera.
      appBar: AppBar(
        title: const Text('Take Picture'), // Título da barra superior.
        backgroundColor: Colors.black,
        actions: [
          if (widget.cameras.length > 1) // Se houver mais de uma câmera, eu mostro um seletor.
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: DropdownButton<CameraDescription>(
                dropdownColor: Colors.grey[900],
                value: _selectedCamera,
                items: _cameraDropdownItems, // Meus itens de seleção de câmera.
                onChanged: (camera) {
                  if (camera != null) {
                    _initCamera(camera); // Troco a câmera e a inicializo novamente.
                  }
                },
                underline: const SizedBox(), // Removo a linha padrão do dropdown.
                iconEnabledColor: Colors.white, // Ícone do dropdown branco.
              ),
            ),
        ],
      ),
      body: _isInitialized && _controller != null // Se a câmera estiver inicializada...
          ? Stack(
              children: [
                CameraPreview(_controller!), // Mostro a visualização da câmera.
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton(
                      backgroundColor: const Color(0xFF05D853), // Botão de captura verde.
                      shape: const CircleBorder(), // Botão redondo.
                      onPressed: _takePicture, // Chama minha função de tirar foto.
                      child: _isTakingPicture // Se estiver tirando foto, mostro um indicador.
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.camera_alt, color: Colors.white), // Ícone da câmera.
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white)), // Se não estiver pronta, mostro carregando.
    );
  }
}