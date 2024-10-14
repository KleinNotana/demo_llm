// lib/repository/chat_langchain_repository.dart

import 'dart:convert';
import 'dart:io';
import 'package:demo_llm_gemini/helper/langchain_gemini_helper.dart';
import 'package:flutter/services.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_google/langchain_google.dart';
import '../models/message.dart';

class ChatLangChainRepository {
  // Current instance is a ChatGoogleGenerativeAI
  late final ChatGoogleGenerativeAI _llm;
  late final ConversationChain _chain;

  ChatLangChainRepository({required String apiKey})
      : _llm = ChatGoogleGenerativeAI(
          apiKey: apiKey,
        ) {
    _chain = ConversationChain(llm: _llm);
  }

  Future<String?> sendMessage(String message) async {
    try {
      final response = await _chain.run(message);
      // copy the response to the clipboard for debugging
      // await Clipboard.setData(ClipboardData(text: response));
      return LangChainGemini.getContent(response);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<String?> sendImagePrompt(
      String message, List<String> imagePaths) async {
    try {
      return await sendMessage(message);
    } catch (e) {
      throw Exception('Failed to send image prompt: $e');
    }
  }

  Future<String?> regenerateMessage(
      String message, List<String> imagePaths) async {
    try {
      return await sendMessage(message);
    } catch (e) {
      throw Exception('Failed to regenerate message: $e');
    }
  }
}
