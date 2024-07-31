import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  //String? _cuisine;
  int? _spiceLevel;
  List<String>? _dietaryConstraints;
  

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await dotenv.load();
    final apiKey = dotenv.env['API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      print('No API_KEY environment variable');
      return;
    }
    model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    // Fetch user details
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
           // _cuisine = data[0]['cuisine'];
            _spiceLevel = data[0]['spicelevel'];
            _dietaryConstraints = List<String>.from(data[0]['dietaryConstraints']);
            print('$_dietaryConstraints');
          });
        }
      } else {
        print('Failed to fetch user details');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({"sender": "You", "text": _controller.text});
      });

      var content = [
        Content.text(
          "Recipe Name: ${widget.recipeName}\n"
          "Description: ${widget.recipeDescription}\n"
          "Ingredients: ${widget.ingredients.map((e) => '${e['quantity']} ${e['measurement_unit']} of ${e['name']}').join(', ')}\n"
          "Steps: ${widget.steps.join('. ')}\n"
          //"Cuisine: $_cuisine\n"
          "Spice Level: $_spiceLevel\n"
          "Dietary Restrictions: ${_dietaryConstraints?.join(', ')}\n"
          "Question: ${_controller.text}"
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
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
