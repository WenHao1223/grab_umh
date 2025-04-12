import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> detectIntent(String? inputText) async {
  final url = Uri.parse('https://web-production-6e3de.up.railway.app/predict'); // update if needed

  if (inputText == null || inputText.isEmpty) {
    return null;
  }
  
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': inputText}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['intent'];
    } else {
      print('Intent detection failed: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error calling intent API: $e');
    return null;
  }
}
