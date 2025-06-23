// lib/utils/user_data_manager.dart
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // <<< IMPORTANTE: Adicione esta importação para base64Encode/Decode

class UserDataManager {
  static const _userNameKey = 'userName';
  static const _userPhotoKey = 'userPhoto'; // Para armazenar a foto como String Base64

  // Salva o nome do usuário
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  // Obtém o nome do usuário
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // Salva a foto do usuário (Uint8List convertida para Base64 String)
  static Future<void> saveUserPhoto(Uint8List? photoBytes) async {
    final prefs = await SharedPreferences.getInstance();
    if (photoBytes != null) {
      // --- CORREÇÃO AQUI ---
      // Use base64Encode para converter Uint8List em String Base64
      final String base64String = base64Encode(photoBytes);
      await prefs.setString(_userPhotoKey, base64String);
    } else {
      await prefs.remove(_userPhotoKey); // Remove se a foto for nula
    }
  }

  // Obtém a foto do usuário (String Base64 convertida de volta para Uint8List)
  static Future<Uint8List?> getUserPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final String? base64String = prefs.getString(_userPhotoKey);
    if (base64String != null) {
      // --- CORREÇÃO AQUI ---
      // Use base64Decode para converter String Base64 de volta para Uint8List
      return base64Decode(base64String);
    }
    return null;
  }

  // Limpa todos os dados do usuário (para logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_userPhotoKey);
  }
}