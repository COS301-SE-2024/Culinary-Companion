import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ChatCard extends StatefulWidget {
  final bool showBackButton;

  ChatCard({this.showBackButton = true});

  @override
  _ChatCardState createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final String apiKey = 'YOUR_CHATGPT_API_KEY_HERE'; // Replace with your ChatGPT API key

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({"user": _controller.text});
      });

      final response = await _sendToChatGPT(_controller.text);
      setState(() {
        _messages.add({"bot": response});
        _controller.clear();
      });
    }
  }

  Future<String> _sendToChatGPT(String message) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey', // Ensure the Bearer prefix is added
    };
    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'user', 'content': message},
      ],
      'max_tokens': 150,
      'temperature': 0.7,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        final errorData = jsonDecode(response.body);
        return 'Error: ${errorData['error']['message']}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showBackButton
          ? AppBar(
              title: Text('Ask Chef'),
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                if (message.containsKey("user")) {
                  return ListTile(
                    title: Text("You: ${message["user"]}"),
                  );
                } else {
                  return ListTile(
                    title: Text("Chef: ${message["bot"]}"),
                  );
                }
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
                      hintText: 'Ask chef a question...',
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
