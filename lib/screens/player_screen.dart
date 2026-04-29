import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/audio_player_service.dart';
import '../widgets/play_button.dart';
import '../widgets/progress_bar.dart';
import '../widgets/song_card.dart';

/// Pantalla principal del reproductor de música
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final AudioPlayerService _playerService;

  @override
  void initState() {
    super.initState();
    _playerService = AudioPlayerService();
  }

  @override
  void dispose() {
    _playerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Reproductor',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<PlayerStatus>(
        stream: _playerService.statusStream,
        initialData: _playerService.currentStatus,
        builder: (context, snapshot) {
          final status = snapshot.data!;
          final currentSong = _playerService.currentSong;

          return Column(
            children: [
              // Album Art grande
              _buildAlbumArt(status),
              const SizedBox(height: 24),
              // Info de la canción
              _buildSongInfo(currentSong, status),
              const SizedBox(height: 24),
              // Barra de progreso
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ProgressBar(
                  position: status.position,
                  duration: status.duration,
                  onSeek: _playerService.seek,
                ),
              ),
              const SizedBox(height: 16),
              // Controles de reproducción
              _buildControls(status),
              const SizedBox(height: 24),
              // Lista de canciones
              Expanded(
                child: _buildPlaylist(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlbumArt(PlayerStatus status) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade300,
            Colors.deepPurple.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Icon(
        Icons.music_note,
        size: 100,
        color: Colors.white.withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildSongInfo(Song song, PlayerStatus status) {
    return Column(
      children: [
        Text(
          song.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          song.artist,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          song.album,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildControls(PlayerStatus status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Shuffle
        IconButton(
          onPressed: _playerService.toggleShuffle,
          icon: Icon(
            Icons.shuffle,
            color: status.isShuffle ? Colors.deepPurple : Colors.grey,
          ),
        ),
        // Previous
        IconButton(
          onPressed: _playerService.previous,
          icon: const Icon(
            Icons.skip_previous_rounded,
            size: 36,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 16),
        // Play/Pause
        PlayButton(
          isPlaying: status.state == PlayerState.playing,
          onPressed: _playerService.togglePlayPause,
        ),
        const SizedBox(width: 16),
        // Next
        IconButton(
          onPressed: _playerService.next,
          icon: const Icon(
            Icons.skip_next_rounded,
            size: 36,
            color: Colors.black87,
          ),
        ),
        // Repeat
        IconButton(
          onPressed: _playerService.toggleRepeat,
          icon: Icon(
            Icons.repeat,
            color: status.isRepeating ? Colors.deepPurple : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylist() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.queue_music, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  'Playlist',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _playerService.playlist.length,
              itemBuilder: (context, index) {
                final song = _playerService.playlist[index];
                return StreamBuilder<PlayerStatus>(
                  stream: _playerService.statusStream,
                  builder: (context, snapshot) {
                    final status = snapshot.data!;
                    return SongCard(
                      song: song,
                      isSelected: status.currentIndex == index,
                      onTap: () => _playerService.selectSong(index),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}