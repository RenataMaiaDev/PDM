import 'package:flutter/material.dart';

// Um ValueNotifier simples para notificar mudanças no perfil do usuário
// Você pode usar isso para recarregar a foto do avatar ou o nome em qualquer widget.
class ProfileNotifier extends ChangeNotifier {
  void notifyProfileUpdate() {
    // Notifica todos os listeners (widgets) que algo mudou no perfil.
    notifyListeners();
  }
}

final profileNotifier = ProfileNotifier();