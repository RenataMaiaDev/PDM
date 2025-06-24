import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:spotfy/database/utils/user_data_manager.dart';
import 'package:spotfy/database/utils/profile_notifier.dart';


class UserAvatar extends StatefulWidget {
  // Preciso da ScaffoldKey para conseguir abrir o drawer a partir daqui.
  final GlobalKey<ScaffoldState> scaffoldKey;

  const UserAvatar({super.key, required this.scaffoldKey});

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

// O estado do meu [UserAvatar], onde eu gerencio a foto do perfil.
class _UserAvatarState extends State<UserAvatar> {
  Uint8List? _userPhotoBytes; // Aqui eu guardo os bytes da foto do usuário.

  @override
  void initState() {
    super.initState();
    _loadUserPhoto(); // Assim que o widget nasce, eu carrego a foto.
    // Eu adiciono um listener ao `profileNotifier` para que, se a foto do perfil mudar
    // em qualquer outra tela, este avatar seja atualizado automaticamente.
    profileNotifier.addListener(_loadUserPhoto);
  }

  @override
  void dispose() {
    // É super importante remover o listener quando o widget morre para não ter vazamento de memória.
    profileNotifier.removeListener(_loadUserPhoto);
    super.dispose();
  }

  // Esta função carrega a foto do usuário usando meu `UserDataManager`.
  Future<void> _loadUserPhoto() async {
    final photo = await UserDataManager.getUserPhoto(); // Busco a foto.
    if (mounted) { // Só atualizo o estado se o widget ainda estiver na árvore.
      setState(() {
        _userPhotoBytes = photo; // Atualizo os bytes da foto.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell( // Usei InkWell para ter um efeito visual ao tocar.
      onTap: () {
        // Ao tocar no avatar, eu uso a `scaffoldKey` para abrir o drawer.
        widget.scaffoldKey.currentState?.openEndDrawer();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Dou um espacinho lateral.
        child: CircleAvatar(
          radius: 18, // Tamanho do meu avatar.
          backgroundColor: Colors.grey[700], // Cor de fundo padrão.
          // Se eu tenho bytes da foto, uso `MemoryImage` para exibi-la.
          backgroundImage: _userPhotoBytes != null
              ? MemoryImage(_userPhotoBytes!)
              : null,
          // Se não tiver foto, mostro um ícone de pessoa padrão.
          child: _userPhotoBytes == null
              ? const Icon(Icons.person, color: Colors.white, size: 24)
              : null,
        ),
      ),
    );
  }
}