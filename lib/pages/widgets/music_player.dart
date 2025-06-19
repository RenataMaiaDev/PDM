import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicPlayerButton extends StatefulWidget {
  final String audioPath; // Caminho do arquivo de áudio (asset)
  final String musicTitle; // Título da música, usado para debug e mensagens

  const MusicPlayerButton({
    super.key,
    required this.audioPath,
    required this.musicTitle,
  });

  @override
  State<MusicPlayerButton> createState() => _MusicPlayerButtonState();
}

class _MusicPlayerButtonState extends State<MusicPlayerButton> {
  late AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped; // Estado atual do player
  Duration _duration = Duration.zero; // Duração total da música
  Duration _position = Duration.zero; // Posição atual da reprodução

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    debugPrint('MusicPlayerButton - Inicializado para: ${widget.musicTitle}, Path: ${widget.audioPath}');

    // Monitorar mudanças no estado do player para atualizar UI e estado interno
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
      debugPrint('MusicPlayerButton - [${widget.musicTitle}] PlayerState changed: $state');

      // Quando a música termina, reseta o estado e posição
      if (state == PlayerState.completed) {
        debugPrint('MusicPlayerButton - [${widget.musicTitle}] Player complete.');
        if (mounted) {
          setState(() {
            _playerState = PlayerState.stopped;
            _position = Duration.zero;
          });
        }
      }
    });

    // Atualiza duração total quando disponível
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
      debugPrint('MusicPlayerButton - [${widget.musicTitle}] Duration: ${duration.inSeconds}s');
    });

    // Atualiza a posição atual da música enquanto toca
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    // Log interno do AudioPlayer para facilitar debug
    _audioPlayer.onLog.listen((msg) {
      debugPrint('MusicPlayerButton - [${widget.musicTitle}] AudioPlayers Log: $msg');
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Libera os recursos quando o widget é descartado
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
      // Reproduz o arquivo de áudio do asset
      await _audioPlayer.play(AssetSource(widget.audioPath));
      debugPrint('MusicPlayerButton - [${widget.musicTitle}] Início da reprodução de asset: ${widget.audioPath}');
      // O estado 'playing' será tratado pelo listener onPlayerStateChanged
    } catch (e) {
      debugPrint('MusicPlayerButton - [${widget.musicTitle}] ERRO ao tentar tocar asset ${widget.audioPath}: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao tocar música: $e')));

      // Em caso de erro, garante que o estado volta para parado
      if (mounted) {
        setState(() {
          _playerState = PlayerState.stopped;
          _position = Duration.zero;
        });
      }
    }
  }

  Future<void> _pause() async {
    debugPrint('MusicPlayerButton - [${widget.musicTitle}] Chamado _pause().');
    await _audioPlayer.pause();
    debugPrint('MusicPlayerButton - [${widget.musicTitle}] Pausou.');
  }

  // Formata Duration para MM:SS
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            _playerState == PlayerState.playing
                ? Icons.pause_circle_filled
                : Icons.play_circle_filled,
            size: 40,
            color: Colors.green,
          ),
          onPressed: () {
            if (_playerState == PlayerState.playing) {
              _pause();
            } else {
              _play();
            }
          },
        ),

        // Mostra tempo decorrido / total se a música está tocando e duração conhecida
        if (_playerState != PlayerState.stopped && _duration.inSeconds > 0)
          Text('${_formatDuration(_position)} / ${_formatDuration(_duration)}'),
      ],
    );
  }
}
