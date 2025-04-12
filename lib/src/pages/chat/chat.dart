import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  static const routeName = '/chat';

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  final FlutterTts _flutterTts = FlutterTts(); // TTS instance

  final types.User _user = const types.User(
    id: 'user-id',
    firstName: 'User',
    //imageUrl: 'https://via.placeholder.com/150',
  );

  final types.User _botUser = const types.User(
    id: 'bot-id',
    firstName: 'Bot',
    //imageUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?Text=Bot',
  );

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
  }

  void _loadInitialMessages() {
    final welcome = types.TextMessage(
      author: _botUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: 'Hello! I wait you at gate A. 😄',
    );

    setState(() {
      _messages = [welcome];
    });

    _speak(welcome.text); // Speak initial message
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });

    Future.delayed(const Duration(milliseconds: 500), () async {
      final replyText = _generateBotReply(message.text);

      final botReply = types.TextMessage(
        author: _botUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: replyText,
      );

      setState(() {
        _messages.insert(0, botReply);
      });

      await _speak(replyText); // Bot speaks the reply
    });
  }

  String _generateBotReply(String userText) {
    final responses = [
      "No problem",
      "😄",
      "No worries",
      "Alright.",
      "Okay 👍",
    ];
    return responses[Random().nextInt(responses.length)];
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5); // Optional: slower speech
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _flutterTts.stop(); // Prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Bob Lee')),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        theme: DefaultChatTheme(
          primaryColor: primaryColor,
          sentMessageBodyTextStyle: const TextStyle(color: Colors.white),
          secondaryColor: Colors.grey[200]!,
          receivedMessageBodyTextStyle: const TextStyle(color: Colors.black87),
          inputTextColor: Colors.black,
          inputBackgroundColor: Colors.white,
          sendButtonIcon: Icon(Icons.send, color: primaryColor),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }
}
