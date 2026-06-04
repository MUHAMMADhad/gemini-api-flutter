import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiDataSource {
  final http.Client client;

  GeminiDataSource({http.Client? client}) : client = client ?? http.Client();

  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _model = 'gemini-2.0-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  Future<String> fetchNews() async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY is not set. '
            'Run with: flutter run --dart-define=GEMINI_API_KEY=<your_key>',
      );
    }

    final uri = Uri.parse('$_baseUrl/$_model:generateContent?key=$_apiKey');

    const prompt = '''
You are a technology news curator. Give me the 5 most important tech news stories right now.

Format each story EXACTLY like this, one per line:
**Headline Here** Brief 2-3 sentence summary of the story goes here.

Rules:
- Each story must be on a single line
- Headline must be wrapped in double asterisks **like this**
- Follow the headline immediately with the body text, no line break between them
- No bullet points, numbers, or extra formatting
- No introductory or closing text, just the 5 stories
''';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 1024,
      },
    });

    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = json['candidates'] as List<dynamic>;
      if (candidates.isEmpty) throw Exception('Gemini returned no candidates');

      final content = candidates[0]['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>;
      return (parts[0]['text'] as String).trim();
    } else {
      throw Exception('Gemini API error ${response.statusCode}: ${response.body}');
    }
  }
}