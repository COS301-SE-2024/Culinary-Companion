import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:shared_preferences/shared_preferences.dart';

class ChatWidget extends StatefulWidget {
  final String recipeName;
  final String recipeDescription;
  final List<Map<String, dynamic>> ingredients;
  final List<String> steps;
  final String userId;

  ChatWidget({
    required this.recipeName,
    required this.recipeDescription,
    required this.ingredients,
    required this.steps,
    required this.userId,
  });

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  late final GenerativeModel model;

  int? _spiceLevel;
  List<String>? _dietaryConstraints;
  List<String> _suggestedPrompts = [];

  @override
  void initState() {
    super.initState();
    _initializeChat();
    //_generateSuggestedPrompts();
  }

  Future<void> _initializeChat() async {
    await dotenv.load();
    final apiKey = dotenv.env['API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      print('No API_KEY environment variable');
      return;
    }
    model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    await _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final String url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'getUserDetails', 'userId': widget.userId}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            _spiceLevel = data[0]['spicelevel'];//users prefered spice level from 0 to 5
            _dietaryConstraints = List<String>.from(data[0]['dietaryConstraints']);
             print('$_dietaryConstraints');
             _generateSuggestedPrompts();
          });
        }
      } else {
        print('Failed to fetch user details');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  void _generateSuggestedPrompts() {
   
  if (_dietaryConstraints != null && _dietaryConstraints!.isNotEmpty) {
    for (String constraint in _dietaryConstraints!) {
      _suggestedPrompts.add("Can I make this recipe $constraint?");
    }
  }

  _suggestedPrompts.addAll([
    "How can I make this recipe spicier?",
   // "What can I substitute for an ingredient I don't have?",
    "What are some tips for cooking this dish?",
    "Explain step 1 of the recipe more clearly",
  ]);
}


  void _sendMessage({String? message}) async {
    String text = message ?? _controller.text;

    if (text.isNotEmpty) {
      setState(() {
        _messages.add({"sender": "You", "text": text});
      });

      var content = [
        Content.text(//send the recipe details and users preferences for context
          "Recipe Name: ${widget.recipeName}\n"
          "Description: ${widget.recipeDescription}\n"
          "Ingredients: ${widget.ingredients.map((e) => '${e['quantity']} ${e['measurement_unit']} of ${e['name']}').join(', ')}\n"
          "Steps: ${widget.steps.join('. ')}\n"
          "Spice Level: $_spiceLevel\n"
          "Dietary Restrictions: ${_dietaryConstraints?.join(', ')}\n"
          "Question: $text"
        )
      ];

      var response = await model.generateContent(content);
      setState(() {
        _messages.add({"sender": "Chef Tess", "text": response.text ?? 'No response text'});
      });
      _controller.clear();
    }
  }

  Widget _buildMessageBubble(String sender, String text) {
    bool isUser = sender == "You";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isUser ? Color.fromARGB(174, 28, 99, 65) : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isUser ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 5),
            Text(
              text,
              style: TextStyle(color: isUser ? Color.fromARGB(255, 252, 250, 250) : Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(179, 34, 58, 42),
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_suggestedPrompts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: _suggestedPrompts.map((prompt) { 
                  return ActionChip(
                    label: Text(prompt),
                    onPressed: () => _sendMessage(message: prompt),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message["sender"]!, message["text"]!);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Ask chef for help',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
