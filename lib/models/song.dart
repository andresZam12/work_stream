/// Modelo simple para representar una canción
class Song {
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String coverUrl;

  const Song({
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    this.coverUrl = '',
  });
}