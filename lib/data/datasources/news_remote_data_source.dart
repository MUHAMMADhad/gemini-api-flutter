import 'package:http/http.dart' as http;

import '../models/news_item.dart';

class NewsRemoteDataSource {
  final http.Client client;

  NewsRemoteDataSource({http.Client? client}) : client = client ?? http.Client();

  static const _baseUrl =
      'https://news-curator-3494615909.us-central1.run.app/news';

  Future<List<NewsItem>> fetchNews() async {
    final response = await client.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      return _parseNews(response.body);
    } else {
      throw Exception('Failed to load news (${response.statusCode})');
    }
  }

  List<NewsItem> _parseNews(String rawText) {
    final List<NewsItem> news = [];

    final lines =
        rawText.split('\n').where((line) => line.trim().isNotEmpty).toList();

    for (final line in lines) {
      if (line.contains('**')) {
        final regex = RegExp(r'\*\*(.+?)\*\*');
        final match = regex.firstMatch(line);

        if (match != null) {
          final headline = match.group(1) ?? '';
          final body =
              line.replaceAll(regex, '').trim().replaceAll('*', '').trim();

          news.add(
            NewsItem(
              headline: headline,
              body: body.isEmpty
                  ? 'Read more about this tech trend.'
                  : body,
            ),
          );
        }
      }
    }

    return news;
  }
}


