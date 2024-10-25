import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../widgets/chat_widget.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ChatWidget(),
    );
  }
}
