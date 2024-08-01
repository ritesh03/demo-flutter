class AlbumArgs {
  AlbumArgs({
    required this.id,
    this.thumbnail,
    this.title,
  });

  final String id;
  final String? thumbnail;
  final String? title;
}
