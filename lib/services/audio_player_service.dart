import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/song.dart';

/// Estado actual del reproductor
enum PlayerState { stopped, playing, paused }

/// Estado completo del reproductor
class PlayerStatus {
  final PlayerState state;
  final Duration position;
  final Duration duration;
  final int currentIndex;
  final bool isShuffle;
  final bool isRepeating;

  const PlayerStatus({
    this.state = PlayerState.stopped,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentIndex = 0,
    this.isShuffle = false,
    this.isRepeating = false,
  });

  PlayerStatus copyWith({
    PlayerState? state,
    Duration? position,
    Duration? duration,
    int? currentIndex,
    bool? isShuffle,
    bool? isRepeating,
  }) {
    return PlayerStatus(
      state: state ?? this.state,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentIndex: currentIndex ?? this.currentIndex,
      isShuffle: isShuffle ?? this.isShuffle,
      isRepeating: isRepeating ?? this.isRepeating,
    );
  }
}

/// Servicio que gestiona el reproductor usando StreamController
class AudioPlayerService {
  // StreamController para emitir el estado del reproductor
  final StreamController<PlayerStatus> _statusController =
      StreamController<PlayerStatus>.broadcast();

  // Estado interno
  PlayerStatus _currentStatus = const PlayerStatus();
  Timer? _progressTimer;

  // Playlist de ejemplo
  final List<Song> playlist = [
    const Song(
      title: 'Midnight City',
      artist: 'M83',
      album: 'Hurry Up, We\'re Dreaming',
      duration: Duration(minutes: 4, seconds: 3),
    ),
    const Song(
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      album: 'After Hours',
      duration: Duration(minutes: 3, seconds: 20),
    ),
    const Song(
      title: 'Take On Me',
      artist: 'a-ha',
      album: 'Hunting High and Low',
      duration: Duration(minutes: 3, seconds: 45),
    ),
    const Song(
      title: 'Electric Feel',
      artist: 'MGMT',
      album: 'Oracular Spectacular',
      duration: Duration(minutes: 4, seconds: 6),
    ),
    const Song(
      title: 'Starboy',
      artist: 'The Weeknd ft. Daft Punk',
      album: 'Starboy',
      duration: Duration(minutes: 3, seconds: 50),
    ),
  ];

  // Exponer el stream para que los widgets listen
  Stream<PlayerStatus> get statusStream => _statusController.stream;

  // Estado actual
  PlayerStatus get currentStatus => _currentStatus;

  // Canción actual
  Song get currentSong => playlist[_currentStatus.currentIndex];

  AudioPlayerService() {
    // Inicializar con la primera canción
    _currentStatus = PlayerStatus(
      state: PlayerState.stopped,
      position: Duration.zero,
      duration: playlist[0].duration,
      currentIndex: 0,
    );
  }

  /// Reproducir
  void play() {
    _currentStatus = _currentStatus.copyWith(state: PlayerState.playing);
    _emitStatus();
    _startProgressTimer();
  }

  /// Pausar
  void pause() {
    _currentStatus = _currentStatus.copyWith(state: PlayerState.paused);
    _emitStatus();
    _stopProgressTimer();
  }

  /// Alternar play/pause
  void togglePlayPause() {
    if (_currentStatus.state == PlayerState.playing) {
      pause();
    } else {
      play();
    }
  }

  /// Siguiente canción
  void next() {
    int nextIndex = _currentStatus.currentIndex + 1;
    if (nextIndex >= playlist.length) {
      nextIndex = 0;
    }
    _currentStatus = _currentStatus.copyWith(
      currentIndex: nextIndex,
      position: Duration.zero,
      duration: playlist[nextIndex].duration,
    );
    _emitStatus();
    if (_currentStatus.state == PlayerState.playing) {
      _restartTimer();
    }
  }

  /// Canción anterior
  void previous() {
    // Si position > 3 segundos, reiniciar canción actual
    if (_currentStatus.position.inSeconds > 3) {
      seek(Duration.zero);
      return;
    }
    int prevIndex = _currentStatus.currentIndex - 1;
    if (prevIndex < 0) {
      prevIndex = playlist.length - 1;
    }
    _currentStatus = _currentStatus.copyWith(
      currentIndex: prevIndex,
      position: Duration.zero,
      duration: playlist[prevIndex].duration,
    );
    _emitStatus();
    if (_currentStatus.state == PlayerState.playing) {
      _restartTimer();
    }
  }

  /// Buscar a una posición específica
  void seek(Duration position) {
    _currentStatus = _currentStatus.copyWith(position: position);
    _emitStatus();
  }

  /// Alternar shuffle
  void toggleShuffle() {
    _currentStatus = _currentStatus.copyWith(
      isShuffle: !_currentStatus.isShuffle,
    );
    _emitStatus();
  }

  /// Alternar repeat
  void toggleRepeat() {
    _currentStatus = _currentStatus.copyWith(
      isRepeating: !_currentStatus.isRepeating,
    );
    _emitStatus();
  }

  /// Seleccionar canción por índice
  void selectSong(int index) {
    if (index >= 0 && index < playlist.length) {
      _currentStatus = _currentStatus.copyWith(
        currentIndex: index,
        position: Duration.zero,
        duration: playlist[index].duration,
      );
      _emitStatus();
    }
  }

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_currentStatus.state == PlayerState.playing) {
        final newPosition = _currentStatus.position + const Duration(seconds: 1);
        if (newPosition >= _currentStatus.duration) {
          // Canción terminada
          if (_currentStatus.isRepeating) {
            seek(Duration.zero);
          } else {
            next();
          }
        } else {
          _currentStatus = _currentStatus.copyWith(position: newPosition);
          _emitStatus();
        }
      }
    });
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  void _restartTimer() {
    _stopProgressTimer();
    _startProgressTimer();
  }

  void _emitStatus() {
    if (!_statusController.isClosed) {
      _statusController.add(_currentStatus);
    }
  }

  void dispose() {
    _stopProgressTimer();
    _statusController.close();
  }
}

