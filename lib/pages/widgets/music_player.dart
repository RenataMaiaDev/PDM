import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Minha biblioteca de áudio.

/// Meu botão de "Play/Pause" para músicas.
class MusicPlayerButton extends StatefulWidget {
  final String audioPath; // Caminho do arquivo de áudio.
  final String musicTitle; // Título da música (para debug).
  final double iconSize; // Tamanho do ícone.
  final Color iconColor; // Cor do ícone.
  final Color? backgroundColor; // Cor de fundo opcional.

  const MusicPlayerButton({
    super.key,
    required this.audioPath,
    required this.musicTitle,
    this.iconSize = 40,
    this.iconColor = Colors.green,
    this.backgroundColor,
  });

  @override
  State<MusicPlayerButton> createState() => _MusicPlayerButtonState();
}

/// Estado que gerencia a reprodução do áudio.
class _MusicPlayerButtonState extends State<MusicPlayerButton> {
  late AudioPlayer _audioPlayer; // Meu player de áudio.
  PlayerState _playerState = PlayerState.stopped; // Estado atual: parado, tocando, pausado.

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // Inicializo o player.
    debugPrint('MusicPlayerButton - Inicializado: ${widget.musicTitle}');

    // Escuto mudanças de estado do player para atualizar a UI.
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
      debugPrint('MusicPlayerButton - [${widget.musicTitle}] Estado: $state');
      // Quando a música termina, volto para o estado parado.
      if (state == PlayerState.completed) {
        if (mounted) {
          setState(() {
            _playerState = PlayerState.stopped;
          });
        }
      }
    });

    // Logs do audioplayers para debug.
    _audioPlayer.onLog.listen((msg) {
      debugPrint('MusicPlayerButton - [${widget.musicTitle}] Log: $msg');
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Libero os recursos do player.
    debugPrint('MusicPlayerButton - Dispose: ${widget.musicTitle}');
    super.dispose();
  }

  /// Toca a música.
  Future<void> _play() async {
    debugPrint('MusicPlayerButton - [${widget.musicTitle}] Play. Estado: $_playerState');
    if (widget.audioPath.isEmpty) {
      debugPrint('MusicPlayerButton - [${widget.musicTitle}] Caminho do áudio vazio.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caminho do áudio não especificado.')),
      );
      return;
    }
    try {
      // Começo a tocar o arquivo de áudio (assumo que é um asset local).
      await _audioPlayer.play(AssetSource(widget.audioPath));
      debugPrint('MusicPlayerButton - [${widget.musicTitle}] Reproduzindo: ${widget.audioPath}');
    } catch (e) {
      debugPrint('MusicPlayerButton - [${widget.musicTitle}] ERRO ao tocar: $e');
      if (mounted) {
        setState(() {
          _playerState = PlayerState.stopped;
        });
      }
    }
  }

  /// Pausa a música.
  Future<void> _pause() async {
    debugPrint('MusicPlayerButton - [${widget.musicTitle}] Pause.');
    await _audioPlayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Se houver cor de fundo, crio um círculo para o botão.
      decoration: widget.backgroundColor != null
          ? BoxDecoration(
              color: widget.backgroundColor,
              shape: BoxShape.circle,
            )
          : null,
      child: IconButton(
        icon: Icon(
          // Ícone muda entre play e pause.
          _playerState == PlayerState.playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
          size: widget.iconSize,
          color: widget.iconColor,
        ),
        onPressed: () {
          // Alterno entre pausar e tocar.
          if (_playerState == PlayerState.playing) {
            _pause();
          } else {
            _play();
          }
        },
      ),
    );
  }
}