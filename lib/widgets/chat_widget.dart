import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatWidget extends StatefulWidget {
  final String recipeName;
  final String recipeDescription;
  final List<Map<String, dynamic>> ingredients;
  final List<String> steps;

  ChatWidget({
    required this.recipeName,
    required this.recipeDescription,
    required this.ingredients,
    required this.steps,
  });

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  late final GenerativeModel model;

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
