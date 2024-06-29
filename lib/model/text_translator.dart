// text_translator.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> translateText(String textToTranslate) async {
  final apiTranslate = dotenv.env['API_TRANSLATE'];
  const endpoint = 'https://google-translator9.p.rapidapi.com/v2';
  final url = Uri.parse(endpoint);

  try {
    final Map<String, dynamic> body = {
      'q': textToTranslate,
      'source': 'vi',
      'target': 'en',
      'format': 'text'
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-RapidAPI-Key': apiTranslate!,
        'X-RapidAPI-Host': 'google-translator9.p.rapidapi.com',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final translatedText = responseBody['data']['translations'][0]['translatedText'];
      return translatedText;
    } else {
      throw Exception('Failed to translate text');
    }
  } catch (e) {
    throw Exception('Failed to translate text');
  }
}
