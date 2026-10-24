import '../models.dart';

/// Returns the selected video and its collection episodes in API order.
List<FeedItem> buildVideoFeed(List<ApiVideo> videos, ApiVideo selectedVideo) {
  final collections = _groupVideos(videos);
  final selectedCollectionIndex = collections.indexWhere(
    (collection) => collection.any((video) => video.id == selectedVideo.id),
  );
  if (selectedCollectionIndex < 0) {
    return [FeedItem(video: selectedVideo)];
  }

  final orderedCollections = [
    ...collections.skip(selectedCollectionIndex),
    ...collections.take(selectedCollectionIndex),
  ];
  return orderedCollections
      .expand((collection) => collection)
      .map((video) => FeedItem(video: video))
      .toList();
}

/// One first-episode preview per collection, preserving API collection order.
List<ApiVideo> buildCollectionPreviews(List<ApiVideo> videos) {
  return _groupVideos(videos).map((collection) => collection.first).toList();
}

List<ApiVideo> buildTrendingVideos(List<ApiVideo> videos) {
  return videos.take(2).toList();
}

List<ApiVideo> buildForYouVideos(List<ApiVideo> videos) {
  return videos.skip(2).toList();
}

List<FeedItem> buildVideoPreviewFeed(List<ApiVideo> videos) {
  return buildCollectionPreviews(videos)
      .map((video) => FeedItem(video: video))
      .toList();
}

List<List<ApiVideo>> _groupVideos(List<ApiVideo> videos) {
  final collections = <List<ApiVideo>>[];
  final collectionIndexes = <String, int>{};
  for (final video in videos) {
    final collectionId = video.collectionId;
    if (collectionId == null) {
      collections.add([video]);
      continue;
    }

    final collectionIndex = collectionIndexes[collectionId];
    if (collectionIndex == null) {
      collectionIndexes[collectionId] = collections.length;
      collections.add([video]);
    } else {
      collections[collectionIndex].add(video);
    }
  }
  for (final collection in collections) {
    if (collection.every((video) => video.episodeNumber != null)) {
      collection.sort(
        (a, b) => a.episodeNumber!.compareTo(b.episodeNumber!),
      );
    }
  }
  return collections;
}
