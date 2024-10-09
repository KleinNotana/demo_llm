import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/chat_screen.dart';
import 'repositories/chat_repository.dart';
import 'blocs/chat/chat_bloc.dart';

const String _apiKey = String.fromEnvironment('API_KEY');

void main() {
  final chatRepository = ChatRepository(apiKey: _apiKey);
  runApp(FlutterGeminiExample(chatRepository: chatRepository));
}

class FlutterGeminiExample extends StatelessWidget {
  final ChatRepository chatRepository;

  const FlutterGeminiExample({Key? key, required this.chatRepository})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(chatRepository: chatRepository),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter ChatBot + Gemini',
        theme: ThemeData(
          fontFamily: 'Arial',
          scaffoldBackgroundColor: const Color(0xFF212121),
          colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark, seedColor: const Color(0xffb0b0b0)),
          useMaterial3: true,
        ),
        home: const ChatScreen(title: 'Flutter ChatBot + Gemini'),
      ),
    );
  }
}
