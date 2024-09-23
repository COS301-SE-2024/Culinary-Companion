import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatWidget extends StatefulWidget {
  final String recipeName;
  final String recipeDescription;
  final List<Map<String, dynamic>> ingredients;
  final List<String> steps;
  final String userId;
  final String course;
  //final VoidCallback onClearConversation;

  ChatWidget({
    required this.recipeName,
    required this.recipeDescription,
    required this.ingredients,
    required this.steps,
    required this.userId,
    required this.course,
    // required this.onClearConversation,
  });

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  late final GenerativeModel model;

  final ScrollController _chatScrollController = ScrollController();

  int? _spiceLevel;
  String? _profilePhoto;
  List<String>? _dietaryConstraints;
  List<String> _suggestedPrompts = [];

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _loadConversation();
    //_generateSuggestedPrompts();
  }

  @override
  void dispose() {
    _chatScrollController.dispose();
    super.dispose();
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
          if (mounted) {
            setState(() {
              _profilePhoto =
                  data[0]['profilephoto']?.toString() ?? 'assets/pfp.jpg';
              _spiceLevel = data[0]
                  ['spicelevel']; //users prefered spice level from 0 to 5
              _dietaryConstraints =
                  List<String>.from(data[0]['dietaryConstraints']);
              // print('$_dietaryConstraints');
              _generateSuggestedPrompts();
              //_loadConversation();
            });
          }
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
      // Limit to a maximum of 2 dietary constraints
      for (int i = 0; i < _dietaryConstraints!.length && i < 2; i++) {
        _suggestedPrompts
            .add("Can I make this recipe ${_dietaryConstraints![i]}?");
      }
    }

    if (_spiceLevel != null &&
        !widget.course.toLowerCase().contains('dessert')) {
      if (_spiceLevel! > 3) {
        _suggestedPrompts.add("How can I make this recipe spicier?");
      } else {
        _suggestedPrompts
            .add("How can I tone down the spiciness of this recipe?");
      }
    }
    //print('${widget.recipeDescription}');
    if (widget.course.toLowerCase().contains('dessert')) {
      _suggestedPrompts.add("Can I make this dessert healthier?");
    }

    _suggestedPrompts.addAll([
      //"How can I make this recipe spicier?",
      // "What can I substitute for an ingredient I don't have?",
      "What are some tips for cooking this dish?",
      "Explain step 1 of the recipe more clearly",
    ]);
  }

  void _sendMessage({String? message}) async {
    String text = message ?? _controller.text;
    _controller.clear();

    if (text.isNotEmpty) {
      if (mounted) {
        setState(() {
          _messages.add({"sender": "You", "text": text});
        });
        await _saveConversation(); // Save conversation after user sends a message
      }

      Future.delayed(Duration(milliseconds: 100), () {
        if (_chatScrollController.hasClients) {
          _chatScrollController.animateTo(
            _chatScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      var content = [
        Content.text("Recipe Name: ${widget.recipeName}\n"
            "Description: ${widget.recipeDescription}\n"
            "Ingredients: ${widget.ingredients.map((e) => '${e['quantity']} ${e['measurement_unit']} of ${e['name']}').join(', ')}\n"
            "Steps: ${widget.steps.join('. ')}\n"
            "Spice Level: $_spiceLevel\n"
            "Dietary Restrictions: ${_dietaryConstraints?.join(', ')}\n"
            "Question: $text")
      ];

      var response = await model.generateContent(content);
      if (mounted) {
        setState(() {
          _messages.add({
            "sender": "Chef Tess",
            "text": response.text ?? 'No response text'
          });
        });
        await _saveConversation(); // Save conversation after receiving a response
      }

      Future.delayed(Duration(milliseconds: 100), () {
        if (_chatScrollController.hasClients) {
          _chatScrollController.animateTo(
            _chatScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _saveConversation() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> messagesToSave =
        _messages.map((message) => jsonEncode(message)).toList();

    await prefs.setStringList(
        'chat_conversation_${widget.recipeName}', messagesToSave);
  }

  Future<void> _loadConversation() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedMessages =
        prefs.getStringList('chat_conversation_${widget.recipeName}');

    if (savedMessages != null) {
      setState(() {
        _messages.addAll(savedMessages.map((msg) {
          // Decode the JSON string
          Map<String, dynamic> jsonMap = jsonDecode(msg);

          // Check and safely convert to Map<String, String> if possible
          return jsonMap.map((key, value) => MapEntry(key.toString(),
              value.toString())); // Ensure both key and value are strings
        }).toList());
      });
    }
    Future.delayed(Duration(milliseconds: 50), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Future<void> _clearConversation() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('chat_conversation_${widget.recipeName}');
  // }

  Widget _buildMessageBubble(String sender, String text) {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    bool isUser = sender == "You";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isUser)
            Image.asset(
              isLightTheme ? 'assets/chef-dark.png' : 'assets/chef.png',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          SizedBox(width: 8.0),
          Flexible(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color:
                    isUser ? Color.fromARGB(255, 56, 68, 65) : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  MarkdownBody(
                    data: text,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        color: isUser
                            ? Color.fromARGB(255, 252, 250, 250)
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser)
            // Display profile photo for user
            ClipOval(
              child: _profilePhoto != null && _profilePhoto!.startsWith('http')
                  ? Image.network(
                      _profilePhoto!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      _profilePhoto ?? 'assets/pfp.jpg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF283330) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Header
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.all(12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    isLightTheme ? 'assets/chef-dark.png' : 'assets/chef.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 12.0),
                  Text(
                    'Robo-Chef',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _chatScrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Message
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        isLightTheme
                            ? 'assets/chef-dark.png'
                            : 'assets/chef.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 8.0),
                      Flexible(
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Text(
                                "Hello! I'm Robo-Chef, here to help you with any questions you might have about this ${widget.recipeName} recipe.",
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_suggestedPrompts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 6.0,
                        runSpacing: 6.0,
                        children: _suggestedPrompts.map((prompt) {
                          return ActionChip(
                            label: Text(
                              prompt,
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Color.fromARGB(255, 56, 68, 65),
                            onPressed: () => _sendMessage(message: prompt),
                          );
                        }).toList(),
                      ),
                    ),
                  // Message List
                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                        NeverScrollableScrollPhysics(), // Prevent internal scrolling
                    padding: EdgeInsets.all(10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(
                          message["sender"]!, message["text"]!);
                    },
                  ),
                  SizedBox(
                      height:
                          60), // Add some space to ensure text input is not covered
                ],
              ),
            ),
          ),
          // Text Input and Send Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Ask Robo-Chef for help',
                      fillColor: Colors.transparent,
                      filled: true,
                      labelStyle: TextStyle(
                        color: textColor,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right_rounded),
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
