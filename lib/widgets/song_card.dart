import 'package:flutter/material.dart';
import '../models/song.dart';

/// Widget para mostrar una canción en la lista
class SongCard extends StatelessWidget {
  final Song song;
  final bool isSelected;
  final VoidCallback onTap;

  const SongCard({
    super.key,
    required this.song,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.deepPurple.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSelected
                  ? [Colors.deepPurple, Colors.purple]
                  : [Colors.grey.shade400, Colors.grey.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.music_note,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          song.title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.deepPurple : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatDuration(song.duration),
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}