import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ChatAPI {
  static String _apiKey = "YOUR OPENAI KEY HERE"; // <--INSERT KEY

  static double _apiTemp = 0.8;
  static String _apiVersion = "text-davinci-003";
  static String _context = "";

  static void updateApiKey(String newApiKey) {
    _apiKey = newApiKey;
  }

  static void updateApiTemperature(double newAPITemp) {
    _apiTemp = newAPITemp;
  }

  static void updateApiVersion(String newApiVersion) {
    _apiVersion = newApiVersion;
  }

  static void updateContext(String newContext) {
    _context = newContext;
  }

  static Future<String> generateResponse(String input) async {
    String model = _apiVersion;
    String prompt = input;

    String url = "https://api.openai.com/v1/engines/$model/completions";

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $_apiKey"
    };

    Map<String, dynamic> body = {
      "prompt": "you are a chat bot" + _context + prompt,
      "max_tokens": 2000,
      "n": 1,
      "stop": "",
      "temperature": _apiTemp
    };

    http.Response response = await http.post(
        Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> responseJson = jsonDecode(responseBody);
      String generatedResponse = responseJson['choices'][0]['text'];
      // update context for next prompt
      String currentPrompt = prompt;
      print(currentPrompt);
      _context += prompt + generatedResponse + "\n";
      return generatedResponse;
    } else {
      return 'Error: No response from API';
    }
  }
  static Future<List<Uint8List>> generateImages(String prompt, int numImages) async {
    String model = "image-alpha-001";
    String url = "https://api.openai.com/v1/images/generations";

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $_apiKey"
    };

    Map<String, dynamic> body = {
      "model": model,
      "prompt": prompt,
      "num_images": numImages,
      "size": "1024x1024",
      "response_format": "url"
    };

    http.Response response = await http.post(
        Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      List<Uint8List> imageList = [];

      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> responseJson = jsonDecode(responseBody);

      List<dynamic> imageDataList = responseJson['data'];
      for (dynamic imageData in imageDataList) {
        String imageUrl = imageData['url'];

        // Download image data from the URL
        http.Response imageDataResponse = await http.get(Uri.parse(imageUrl));
        if (imageDataResponse.statusCode == 200) {
          imageList.add(imageDataResponse.bodyBytes);
        } else {
          throw Exception('Failed to download image data');
        }
      }

      return imageList;
    } else {
      throw Exception('Failed to generate image');
    }
  }

}
