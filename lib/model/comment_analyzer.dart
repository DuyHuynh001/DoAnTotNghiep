// comment_analyzer.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Google Perspective API: API này cung cấp các công cụ để phân tích 
  // và đánh giá tính độc hại của văn bản, bao gồm phân loại những nội dung có thể gây phản cảm, thiếu văn hóa.

Future<Map<String, dynamic>> analyzeComment(String comment) async {
  final apiKey = dotenv.env['API_KEY']; // Replace with your actual API key
  final url = 'https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=$apiKey';
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'comment': {'text': comment},
        'requestedAttributes': {'TOXICITY': {}},
        'languages':['en'],  // chỉ hỗ trợ tiếng anh
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to analyze comment');
    }
  } catch (e) {
    throw Exception('Failed to analyze comment');
  }
}

