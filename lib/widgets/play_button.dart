import 'package:flutter/material.dart';

/// Widget para el botón de play/pause
class PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  const PlayButton({
    super.key,
    required this.isPlaying,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.deepPurple,
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}