import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models.dart';

typedef VideoLoader = Future<List<ApiVideo>> Function();

class VideosService {
  VideosService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri endpoint =
      Uri.parse('https://reelspay.beamaxtech.com.ng/api/videos');

  final http.Client _client;

  Future<List<ApiVideo>> fetchVideos() async {
    final videos = <ApiVideo>[];
    final visitedPages = <Uri>{};
    Uri? pageUri = endpoint;

    while (pageUri != null) {
      if (!visitedPages.add(pageUri)) {
        throw const FormatException(
            'The videos API returned a pagination loop.');
      }
      final response =
          await _client.get(pageUri).timeout(const Duration(seconds: 25));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw http.ClientException(
          'Videos API returned HTTP ${response.statusCode}.',
          pageUri,
        );
      }
      final page = parsePage(response.body);
      videos.addAll(page.videos);
      pageUri = page.nextPage;
    }

    return videos;
  }

  static VideosPage parsePage(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic> || decoded['data'] is! List) {
      throw const FormatException(
          'The videos API response has an invalid shape.');
    }

    final videos = <ApiVideo>[];
    for (final record in decoded['data'] as List) {
      if (record is! Map<String, dynamic>) {
        throw const FormatException(
            'The videos API returned an invalid video record.');
      }
      if (record['type'] == 'collection') {
        final episodes = record['episodes'];
        if (episodes is! List) {
          throw const FormatException(
              'The videos API returned a collection without an episodes list.');
        }
        final collectionId = record['collection_id'] ?? record['id'];
        final collectionTitle = record['collection_title'] ?? record['title'];
        final coverUrl = record['cover_thumbnail_url'] ??
            record['thumbnail_url'] ??
            record['thumbnail'];
        final episodeCount = record['episode_count'];
        for (var index = episodes.length - 1; index >= 0; index--) {
          final episode = episodes[index];
          if (episode is! Map<String, dynamic>) {
            throw const FormatException(
                'The videos API returned an invalid collection episode.');
          }
          videos.add(
            ApiVideo.fromJson(
              episode,
              normalizeMediaUrl: normalizeMediaUrl,
              defaultCollectionId: collectionId?.toString(),
              defaultCollectionTitle:
                  collectionTitle is String ? collectionTitle.trim() : null,
              defaultCollectionCoverUrl: coverUrl is String ? coverUrl : null,
              defaultCollectionEpisodeCount: episodeCount is int
                  ? episodeCount
                  : int.tryParse(episodeCount?.toString() ?? ''),
              defaultEpisodeNumber: episodes.length - index,
            ),
          );
        }
      } else {
        videos.add(ApiVideo.fromJson(
          record,
          normalizeMediaUrl: normalizeMediaUrl,
        ));
      }
    }

    final nextPageUrl = decoded['next_page_url'];
    final nextPage = nextPageUrl is String && nextPageUrl.isNotEmpty
        ? endpoint.resolve(nextPageUrl)
        : null;
    return VideosPage(videos: videos, nextPage: nextPage);
  }

  static String normalizeMediaUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        (uri.host.toLowerCase() != 'localhost' &&
            uri.host != '127.0.0.1' &&
            uri.host != '0.0.0.0')) {
      return value;
    }
    return Uri.https(
      endpoint.host,
      uri.path,
      uri.queryParameters.isEmpty ? null : uri.queryParameters,
    ).toString();
  }

  void dispose() => _client.close();
}

class VideosPage {
  const VideosPage({required this.videos, required this.nextPage});

  final List<ApiVideo> videos;
  final Uri? nextPage;
}
