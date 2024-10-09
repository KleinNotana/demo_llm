import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/message.dart';

class ChatRepository {
  final GenerativeModel _model;
  late final ChatSession _chat;

  ChatRepository({required String apiKey})
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash-latest',
          apiKey: apiKey,
        ) {
    _chat = _model.startChat();
  }

  Future<String?> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<String?> sendImagePrompt(
      String message, List<String> imagePaths) async {
    try {
      List<Uint8List> imageBytes = [];

      for (String path in imagePaths) {
        final bytes = await File(path).readAsBytes();
        imageBytes.add(bytes);
      }

      final content = Content.multi([
        TextPart(message),
        ...imageBytes.map((bytes) => DataPart('image/jpeg', bytes)),
      ]);

      final response = await _chat.sendMessage(content);
      return response.text;
    } catch (e) {
      throw Exception('Failed to send image prompt: $e');
    }
  }

  Future<String?> regenerateMessage(
      String message, List<String> imagePaths) async {
    try {
      List<Uint8List> imageBytes = [];

      for (String path in imagePaths) {
        final bytes = await File(path).readAsBytes();
        imageBytes.add(bytes);
      }

      final content = Content.multi([
        TextPart(message),
        ...imageBytes.map((bytes) => DataPart('image/jpeg', bytes)),
      ]);

      final response = await _chat.sendMessage(content);
      return response.text;
    } catch (e) {
      throw Exception('Failed to regenerate message: $e');
    }
  }
}
