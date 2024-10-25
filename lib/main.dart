import 'package:demo_llm_gemini/repositories/chat_langchain_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/chat_screen.dart';
import 'repositories/chat_gemini_repository.dart';
import 'blocs/chat/chat_bloc.dart';

const String _apiKey = String.fromEnvironment('API_KEY');

void main() {
  // Initialize the LangChain repository
  // You can change the repository to ChatRepository() to use the default repository
  // final chatRepository = ChatGeminiRepository(apiKey: _apiKey);
  final chatRepository = ChatLangChainRepository(apiKey: _apiKey);

  // Run the app
  runApp(FlutterGeminiExample(chatRepository: chatRepository));
}

class FlutterGeminiExample extends StatelessWidget {
  final chatRepository;

  const FlutterGeminiExample({Key? key, required this.chatRepository})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;
    return BlocProvider(
      create: (context) => ChatBloc(chatRepository: chatRepository),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
