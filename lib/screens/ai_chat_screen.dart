import 'package:flutter/material.dart';

import '../constants/style_constants.dart';
import '../models/user.dart';
import '../widgets/header.dart';
import '../widgets/sub_header.dart';

class AIChatScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final User user;
  const AIChatScreen({super.key, required this.scaffoldKey, required this.user});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
    });

    _controller.clear();
    _scrollToBottom();

    // Mock AI reply (คุณค่อยไปเชื่อม API จริง)
    Future.delayed(Duration(milliseconds: 400), () {
      setState(() {
        _messages.add(_ChatMessage(
          text: "AI received: $text",
          isUser: false,
        ));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              Header(title: "AI Chat", scaffoldKey: widget.scaffoldKey),
              SizedBox(height: defaultPadding),
              SubHeader(subtitle: 'AI Assistant Welcome ${widget.user.fullName}'),
              SizedBox(height: defaultPadding),

              // ---------------- Chat Messages ----------------
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _ChatBubble(message: msg);
                    },
                  ),
                ),
              ),

              SizedBox(height: defaultPadding / 2),

              // ---------------- Input Field ----------------
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: defaultTextColor),
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: primaryColor),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    bool isUser = message.isUser;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isUser ? primaryColor : Colors.white10,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : defaultTextColor,
          ),
        ),
      ),
    );
  }
}
