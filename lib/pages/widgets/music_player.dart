// lib/widgets/music_player_button.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicPlayerButton extends StatefulWidget {
  final String audioPath;
  final String musicTitle;
  final double iconSize;
  final Color iconColor;
  final Color? backgroundColor;

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

class _MusicPlayerButtonState extends State<MusicPlayerButton> {
  late AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    debugPrint('MusicPlayerButton - Inicializado para: ${widget.musicTitle}, Path: ${widget.audioPath}');

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
      debugPrint('MusicPlayerButton - [${widget.musicTitle}] PlayerState changed: $state');
      if (state == PlayerState.completed) {
        debugPrint('MusicPlayerButton - [${widget.musicTitle}] Player complete.');
        if (mounted) {
          setState(() {
            _playerState = PlayerState.stopped;
          });
        }
      }
    });

    _audioPlayer.onLog.listen((msg) {
      debugPrint('MusicPlayerButton - [${widget.musicTitle}] AudioPlayers Log: $msg');
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    debugPrint('MusicPlayerButton - Dispose para: ${widget.musicTitle}');
    super.dispose();
  }

  Future<void> _play() async {
    debugPrint('MusicPlayerButton - [${widget.musicTitle}] Chamado _play(). Current state: $_playerState');
    if (widget.audioPath.isEmpty) {
      debugPrint('MusicPlayerButton - [${widget.musicTitle}] audioPath está vazio.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caminho do áudio não especificado.')),
      );
      return;
    }
    try {
      await _audioPlayer.play(AssetSource(widget.audioPath));
      debugPrint('MusicPlayerButton - [${widget.musicTitle}] Início da reprodução de asset: ${widget.audioPath}');
    } catch (e) {
      debugPrint('MusicPlayerButton - [${widget.musicTitle}] ERRO FATAL ao tentar tocar asset ${widget.audioPath}: $e');
      if (mounted) {
        setState(() {
          _playerState = PlayerState.stopped;
        });
      }
    }
  }

  Future<void> _pause() async {
    debugPrint('MusicPlayerButton - [${widget.musicTitle}] Chamado _pause().');
    await _audioPlayer.pause();
    debugPrint('MusicPlayerButton - [${widget.musicTitle}] Pausou.');
  }

  // ignore: unused_element
  Future<void> _stop() async {
    debugPrint('MusicPlayerButton - [${widget.musicTitle}] Chamado _stop().');
    await _audioPlayer.stop();
    debugPrint('MusicPlayerButton - [${widget.musicTitle}] Parou.');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.backgroundColor != null
          ? BoxDecoration(
              color: widget.backgroundColor,
              shape: BoxShape.circle,
            )
          : null,
      child: IconButton(
        icon: Icon(
          _playerState == PlayerState.playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
          size: widget.iconSize,
          color: widget.iconColor,
        ),
        onPressed: () {
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