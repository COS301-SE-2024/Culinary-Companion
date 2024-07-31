import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

String decryptApiKey(String encryptedApiKey, String encryptionKey) {
  final key = encrypt.Key.fromUtf8(encryptionKey);
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  final decrypted = encrypter.decrypt64(encryptedApiKey, iv: iv);
  return decrypted;
}

Future<String> fetchContentBackpack() async {
  final encryptedApiKey = dotenv.env['ENCRYPTED_API_KEY'] ?? '';
  final encryptionKey = dotenv.env['ENCRYPTION_KEY'] ?? '';
  if (encryptedApiKey.isEmpty || encryptionKey.isEmpty) {
    return 'Missing API_KEY environment variable';
  }

  final apiKey = decryptApiKey(encryptedApiKey, encryptionKey);

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text('Write a story about a magic backpack.')];
  final response = await model.generateContent(content);

  return response.text ?? 'No response text';
}


Future<String> fetchContentHorse() async {
  final encryptedApiKey = dotenv.env['ENCRYPTED_API_KEY'] ?? '';
  final encryptionKey = dotenv.env['ENCRYPTION_KEY'] ?? '';
  if (encryptedApiKey.isEmpty || encryptionKey.isEmpty) {
    return 'Missing API_KEY environment variable';
  }

    final apiKey = decryptApiKey(encryptedApiKey, encryptionKey);

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text('Write a story about a horse.')];
  final response = await model.generateContent(content);

  return response.text ?? 'No response text';
}

// Future<String> fetchFormattedRecipe(String recipeText) async {
//   await dotenv.load();
//   final apiKey = dotenv.env['API_KEY'] ?? '';
//   if (apiKey.isEmpty) {
//     return 'No API_KEY environment variable';
//   }
//   //print('here1');
//   final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
//   final content = [
//     Content.text('Format the following recipe for database insertion, including fields: name, description, cookTime, prepTime, servingAmount, cuisine, course, spiceLevel, ingredients (name, quantity, unit), methods, appliances (name). Here is the recipe: $recipeText')
//   ];
//   final response = await model.generateContent(content);
 
//   print('$response');
//   return response.text ?? 'No response text';
  
// }