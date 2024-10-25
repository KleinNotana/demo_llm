import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typewritertext/typewritertext.dart';
import '../../models/chat_session.dart';
import '../../repositories/chat_langchain_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../../../repositories/chat_gemini_repository.dart';
import '../../../models/message.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final chatRepository;
  final List<ChatSession> _chatSessions = [];
  List<Message> _currentSessionMessages = [];
  late TypeWriterController streamController = TypeWriterController(
    text: '',
    duration: const Duration(milliseconds: 1000),
  );

  ChatBloc({required this.chatRepository}) : super(ChatInitial()) {
    on<CreateNewChatSession>(_onCreateNewChatSession);
    on<SendTextMessage>(_onSendTextMessage);
    on<SendImagePrompt>(_onSendImagePrompt);
    on<SaveChatSession>(_onSaveChatSession);
    on<LoadChatSession>(_onLoadChatSession);
    on<LoadSessionList>(_onLoadSessionList);
  }

  Future<void> _onLoadSessionList(
      LoadSessionList event, Emitter<ChatState> emit) async {
    emit(ChatLoaded(List.from(_currentSessionMessages), isLoading: true));

    try {
      emit(ChatLoaded(List.from(_currentSessionMessages),
          chatSessions: _chatSessions, isLoading: false));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendTextMessage(
      SendTextMessage event, Emitter<ChatState> emit) async {
    // Add user message
    _currentSessionMessages
        .add(Message(text: event.message, images: null, isFromUser: true));
    emit(ChatLoaded(List.from(_currentSessionMessages), isLoading: true));

    try {
      final stream =
          chatRepository.sendMessage(event.message).asBroadcastStream();
      final filteredStream =
          stream.where((value) => value != null).cast<String>();
      streamController = TypeWriterController.fromStream(filteredStream);

      String currentMessage = '';
      _currentSessionMessages
          .add(Message(text: currentMessage, images: null, isFromUser: false));

      await for (final chunk in stream) {
        if (chunk != null) {
          currentMessage += chunk;
        }
        _currentSessionMessages.last.text = currentMessage;
        emit(ChatLoaded(List.from(_currentSessionMessages), isLoading: true));
      }
      emit(ChatLoaded(List.from(_currentSessionMessages), isLoading: false));
    } catch (e) {
      emit(ChatError(e.toString()));
      emit(ChatLoaded(List.from(_currentSessionMessages), isLoading: false));
    }
  }

  Future<void> _onSendImagePrompt(
      SendImagePrompt event, Emitter<ChatState> emit) async {
    // imagePaths is a list of String image paths
    print('Image paths: ${event.imagePaths}');
    // Add user messages with images
    if (event.imagePaths.isEmpty) {
      _currentSessionMessages
          .add(Message(text: event.message, images: null, isFromUser: true));
    } else {
      _currentSessionMessages.add(Message(
        text: event.message,
        images: event.imagePaths,
        isFromUser: true,
      ));
    }
    emit(ChatLoaded(List.from(_currentSessionMessages), isLoading: true));
    try {
      // Call Repository to send image prompt and get response
      final response =
          await chatRepository.sendImagePrompt(event.message, event.imagePaths);

      // Save response to messages list
      if (response != null) {
        _currentSessionMessages
            .add(Message(text: response, images: null, isFromUser: false));
        emit(ChatLoaded(List.from(_currentSessionMessages), isLoading: false));
      } else {
        emit(ChatError('No response from API.'));
        emit(ChatLoaded(List.from(_currentSessionMessages), isLoading: false));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
      emit(ChatLoaded(List.from(_currentSessionMessages), isLoading: false));
    }
  }

  Future<void> _onSaveChatSession(
      SaveChatSession event, Emitter<ChatState> emit) async {
    emit(ChatLoaded(List.from(_currentSessionMessages), isLoading: false));

    try {
      final session = ChatSession(
          id: DateTime.now().toIso8601String(),
          messages: List.from(_currentSessionMessages));

      _chatSessions.add(session);

      print(session.toString());

      await chatRepository.saveChatSessionJson(session);

      emit(ChatLoaded(List.from(_currentSessionMessages),
          chatSessions: _chatSessions, isLoading: false));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadChatSession(
      LoadChatSession event, Emitter<ChatState> emit) async {
    emit(ChatLoaded(List.from(_currentSessionMessages), isLoading: true));
    try {
      final messages = await chatRepository
          .restoreChatSessionJsonToChatMemoryHistory(event.sessionId);

      _currentSessionMessages = List.from(messages);

      emit(ChatLoaded(List.from(_currentSessionMessages),
          chatSessions: _chatSessions, isLoading: false));
    } catch (e) {
      emit(ChatError(e.toString()));
      emit(ChatLoaded(List.from(_currentSessionMessages),
          chatSessions: _chatSessions, isLoading: false));
    }
  }

  Future<void> _onCreateNewChatSession(
      CreateNewChatSession event, Emitter<ChatState> emit) async {
    await _onSaveChatSession(SaveChatSession(), emit);

    _currentSessionMessages = [];
    emit(ChatLoaded(List.from(_currentSessionMessages), isLoading: false));
  }
}
