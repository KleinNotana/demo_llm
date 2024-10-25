import 'dart:convert';
import 'dart:io';
import 'package:demo_llm_gemini/models/chat_session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:demo_llm_gemini/helper/langchain_gemini_helper.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_google/langchain_google.dart';
import '../models/message.dart';

class ChatLangChainRepository {
  late final ChatGoogleGenerativeAI _llm;
  late ConversationChain _chain;

  late List<ChatSession> _chatSessions = [];
  late ChatSession _currentSession;

  ChatLangChainRepository({required String apiKey}) {
    _llm = ChatGoogleGenerativeAI(apiKey: apiKey);
    _chain = ConversationChain(llm: _llm);
  }

  Future<List<Message>> restoreChatSessionJsonToChatMemoryHistory(
      String sessionId) async {
    try {
      final path = await _getSessionPath();
      final filePath = '$path/$sessionId.json';
      final file = File(filePath);

      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final chatSession = ChatSession.fromJson(jsonDecode(jsonData));
        // Convert chat session to chat memory history
        var _currentChatMessageHistory = ChatMessageHistory();
        // Add messages to chat memory history
        for (var message in chatSession.messages) {
          if (message.isFromUser) {
            _currentChatMessageHistory.addHumanChatMessage(message.text ?? '');
          } else {
            _currentChatMessageHistory.addAIChatMessage(message.text ?? '');
          }
        }
        // Create a new memory with the chat history
        var _currentMemory = ConversationBufferMemory(
          chatHistory: _currentChatMessageHistory,
        );
        // Create a new conversation chain with the memory
        _chain = ConversationChain(llm: _llm, memory: _currentMemory);
        return chatSession.messages;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to restore chat session: $e');
    }
  }

  Future<String> _getSessionPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    // Create a directory to store chat sessions,  if it doesn't exist
    final dir = Directory('${appDir.path}/chat_sessions');
    if (!await dir.exists()) {
      await dir.create();
    }
    return dir.path;
  }

  Future<void> saveChatSessionJson(ChatSession chatSession) async {
    try {
      final path = await _getSessionPath();
      final filePath = '$path/${chatSession.id}.json';
      final file = File(filePath);

      print('Saving chat session to: $filePath');

      final jsonData = jsonEncode(chatSession.toJson());
      await file.writeAsString(jsonData);
    } catch (e) {
      throw Exception('Failed to save chat session: $e');
    }
  }

  Future<List<String>> getStorageChatSession() async {
    try {
      final path = await _getSessionPath();
      final dir = Directory(path);
      final files = await dir.list().toList();

      var filePathList = files
          .where((file) => file.path.endsWith('.json'))
          .map((file) => file.path)
          .toList();

      // read each file and add it into a ChatSession object
      return filePathList;
    } catch (e) {
      throw Exception('Failed to get chat history: $e');
    }
  }

  Stream<String?> sendMessage(String message) async* {
    try {
      final response = await _chain.run(message);
      yield LangChainGemini.getContent(response);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<Stream<String?>> sendImagePrompt(
      String message, List<String> imagePaths) async {
    try {
      return await sendMessage(message);
    } catch (e) {
      throw Exception('Failed to send image prompt: $e');
    }
  }

  Future<Stream<String?>> regenerateMessage(
      String message, List<String> imagePaths) async {
    try {
      //return await sendMessage(message);
      return await sendMessage(message);
    } catch (e) {
      throw Exception('Failed to regenerate message: $e');
    }
  }

/*
  Stream<String?> sendMessageAndGetChunkResponse(String message) async* {
    try {
      /*final context = _currentContext != null
          ? _currentContext.map((doc) => doc.pageContent).join('\n')
          : '';*/
      final context = '';

      if (context.isEmpty) {
        final prompt = ChatPromptTemplate.fromTemplate('{message}');
        const parser = StringOutputParser<ChatResult>();

        final _chain = prompt.pipe(_llm).pipe(parser);
        final stream = _chain.stream({'message': message});

        await for (final chunk in stream) {
          yield chunk;
        }
      } else {
        final promptTemplate = ChatPromptTemplate.fromTemplate(
            'Answer the question based on the following context:\n{context}\n\nQuestion: {message}');

        // Kết hợp ngữ cảnh và câu hỏi
        final formattedPrompt = promptTemplate.format({
          'context': context,
          'message': message,
        });

        const parser = StringOutputParser<ChatResult>();

        final _chain = promptTemplate.pipe(_llm).pipe(parser);
        final stream = _chain.stream({'message': formattedPrompt});

        // Gửi từng chunk response
        await for (final chunk in stream) {
          yield chunk;
        }
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

*/
}
