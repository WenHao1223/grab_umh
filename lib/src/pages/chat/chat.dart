import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:grab_umh/src/stt/speech_transcriber';
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
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechTranscriber _transcriber = SpeechTranscriber();

  bool _isMicMode = true;

  final types.User _user = const types.User(id: 'user-id', firstName: 'User');
  final types.User _botUser = const types.User(id: 'bot-id', firstName: 'Bot');

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

    _speak(welcome.text);
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

      await _speak(replyText);
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
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(text);
  }

  Future<void> _startSpeechToText() async {
    String? finalResult;
    bool isCompleted = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (!_transcriber.isListening && !isCompleted) {
              _transcriber.startListening().then((result) async {
                finalResult = result;
                isCompleted = true;

                // Wait a short period (like a user pause)
                await Future.delayed(const Duration(seconds: 2));

                // Close the dialog if it's still open
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

                // Send message if not empty
                if (finalResult != null && finalResult!.trim().isNotEmpty) {
                  _transcriber.stopListening;
                  _handleSendPressed(
                    types.PartialText(text: finalResult!.trim()),
                  );
                }
              });
            }

            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Listening..."),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      _transcriber.stopListening();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text("Cancel"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
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
        customBottomWidget: _buildCustomInput(),
        theme: DefaultChatTheme(
          primaryColor: primaryColor,
          sentMessageBodyTextStyle: const TextStyle(color: Colors.white),
          secondaryColor: Colors.grey[200]!,
          receivedMessageBodyTextStyle: const TextStyle(color: Colors.black87),
          inputTextColor: Colors.black,
          inputBackgroundColor: Colors.white,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }

  Widget _buildCustomInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          if (_isMicMode)
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _startSpeechToText,
                icon: const Icon(Icons.mic),
                label: const Text("Hold to talk"),
              ),
            )
          else
            Expanded(
              child: TextField(
                onSubmitted: (value) {
                  if (value.trim().isEmpty) return;
                  _handleSendPressed(types.PartialText(text: value.trim()));
                },
                decoration: InputDecoration(
                  hintText: "Type your message...",
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(_isMicMode ? Icons.keyboard : Icons.mic),
            onPressed: () {
              setState(() {
                _isMicMode = !_isMicMode;
              });
            },
          ),
        ],
      ),
    );
  }
}
