/// ReelsPay data models.

class Drama {
  const Drama({
    required this.id,
    required this.title,
    required this.desc,
    required this.tags,
    required this.episodes,
    required this.poster,
    required this.clips,
    this.badge,
    required this.categories,
    required this.likes,
    required this.comments,
  });

  final String id;
  final String title;
  final String desc;
  final List<String> tags;
  final int episodes;

  /// Asset path of the vertical poster, e.g. 'assets/posters/xxx.png'.
  final String poster;

  /// Bundled demo clips used for this drama's episodes (cycled).
  final List<String> clips;

  /// 'hot' | 'new' | null
  final String? badge;
  final List<String> categories;
  final int likes;
  final int comments;
}

/// One playable page in the vertical reels feed.
class FeedItem {
  const FeedItem({
    required this.key,
    required this.drama,
    required this.ep,
    required this.title,
    required this.clip,
  });

  final String key;
  final Drama drama;

  /// 1-based episode number.
  final int ep;
  final String title;

  /// Bundled asset video path.
  final String clip;
}
