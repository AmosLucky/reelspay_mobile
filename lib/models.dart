/// A video returned by the ReelsPay videos API.
class ApiVideo {
  const ApiVideo({
    required this.id,
    required this.title,
    required this.author,
    required this.videoUrl,
    required this.views,
    required this.likes,
    required this.comments,
    this.thumbnailUrl,
    this.collectionId,
    this.collectionTitle,
    this.collectionCoverUrl,
    this.collectionEpisodeCount,
    this.episodeNumber,
  });

  factory ApiVideo.fromJson(
    Map<String, dynamic> json, {
    required String Function(String) normalizeMediaUrl,
    String? defaultCollectionId,
    String? defaultCollectionTitle,
    String? defaultCollectionCoverUrl,
    int? defaultCollectionEpisodeCount,
    int? defaultEpisodeNumber,
  }) {
    final id = json['id'];
    final title = json['title'];
    final videoUrl = json['video_url'];
    if (id == null || title is! String || videoUrl is! String) {
      throw const FormatException(
          'Video record is missing its id, title, or video_url.');
    }

    final thumbnail = json['thumbnail_url'];
    final alternateThumbnail = json['thumbnail'];
    final author = json['author'];
    final collectionId = json['collection_id'];
    final collectionTitle = json['collection_title'];
    final collectionCover = defaultCollectionCoverUrl ??
        (json['cover_thumbnail_url'] is String
            ? json['cover_thumbnail_url'] as String
            : null);
    final rawEpisodeCount =
        json['episode_count'] ?? defaultCollectionEpisodeCount;
    return ApiVideo(
      id: id.toString(),
      title: title,
      author: author is String ? author : '',
      videoUrl: normalizeMediaUrl(videoUrl),
      thumbnailUrl: thumbnail is String
          ? normalizeMediaUrl(thumbnail)
          : alternateThumbnail is String
              ? normalizeMediaUrl(alternateThumbnail)
              : null,
      collectionId: collectionId?.toString() ?? defaultCollectionId,
      collectionTitle:
          collectionTitle is String && collectionTitle.trim().isNotEmpty
              ? collectionTitle.trim()
              : defaultCollectionTitle,
      collectionCoverUrl:
          collectionCover == null ? null : normalizeMediaUrl(collectionCover),
      collectionEpisodeCount: rawEpisodeCount == null
          ? null
          : _intValue(rawEpisodeCount, 'episode_count'),
      episodeNumber:
          _optionalInt(json['episode_number']) ?? defaultEpisodeNumber,
      views: _intValue(json['views_count'], 'views_count'),
      likes: _intValue(json['likes_count'], 'likes_count'),
      comments: _intValue(json['comments_count'], 'comments_count'),
    );
  }

  final String id;
  final String title;
  final String author;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? collectionId;
  final String? collectionTitle;
  final String? collectionCoverUrl;
  final int? collectionEpisodeCount;
  final int? episodeNumber;
  final int views;
  final int likes;
  final int comments;

  static int _intValue(Object? value, String field) {
    if (value == null) return 0;
    if (value is int) return value;
    final parsed = int.tryParse(value.toString());
    if (parsed == null) {
      throw FormatException('Video field "$field" is not an integer.');
    }
    return parsed;
  }

  static int? _optionalInt(Object? value) {
    if (value == null) return null;
    return _intValue(value, 'episode_number');
  }
}

/// One playable page in a vertical video feed.
class FeedItem {
  const FeedItem({required this.video});

  final ApiVideo video;

  String get key => video.id;
}
