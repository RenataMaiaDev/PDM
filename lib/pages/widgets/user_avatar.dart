// lib/widgets/user_avatar.dart
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:spotfy/database/utils/user_data_manager.dart';
import 'package:spotfy/database/utils/profile_notifier.dart';

class UserAvatar extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const UserAvatar({super.key, required this.scaffoldKey});

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  Uint8List? _userPhotoBytes;

  @override
  void initState() {
    super.initState();
    _loadUserPhoto();
    // Escuta por mudanças no perfil e recarrega a foto
    profileNotifier.addListener(_loadUserPhoto);
  }

  @override
  void dispose() {
    // É crucial remover o listener para evitar vazamentos de memória
    profileNotifier.removeListener(_loadUserPhoto);
    super.dispose();
  }

  // Recarrega a foto do usuário
  Future<void> _loadUserPhoto() async {
    final photo = await UserDataManager.getUserPhoto();
    if (mounted) {
      setState(() {
        _userPhotoBytes = photo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.scaffoldKey.currentState?.openEndDrawer();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey[700],
          backgroundImage: _userPhotoBytes != null
              ? MemoryImage(_userPhotoBytes!)
              : null,
          child: _userPhotoBytes == null
              ? const Icon(Icons.person, color: Colors.white, size: 24)
              : null,
        ),
      ),
    );
  }
}