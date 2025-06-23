// lib/utils/profile_notifier.dart
import 'package:flutter/material.dart';

// Um ValueNotifier simples para notificar mudanças no perfil do usuário
// Você pode usar isso para recarregar a foto do avatar ou o nome em qualquer widget.
class ProfileNotifier extends ChangeNotifier {
  void notifyProfileUpdate() {
    // Notifica todos os listeners (widgets) que algo mudou no perfil.
    notifyListeners();
  }
}

// Crie uma instância global para que possa ser acessada de qualquer lugar.
// Isso permite que diferentes partes do seu app acessem o mesmo notificador.
final profileNotifier = ProfileNotifier();