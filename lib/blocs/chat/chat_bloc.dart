import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../../../repositories/chat_repository.dart';
import '../../../models/message.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final List<Message> _messages = [];

  ChatBloc({required this.chatRepository}) : super(ChatInitial()) {
    on<SendTextMessage>(_onSendTextMessage);
    on<SendImagePrompt>(_onSendImagePrompt);
  }

  Future<void> _onSendTextMessage(
      SendTextMessage event, Emitter<ChatState> emit) async {
    // Add user message
    _messages.add(Message(text: event.message, images: null, isFromUser: true));
    // Emit ChatLoaded state with user message
    emit(ChatLoaded(List.from(_messages), isLoading: true));
    try {
      // Call Repository to send message and get response
      final response = await chatRepository.sendMessage(event.message);

      // Save response to messages list
      if (response != null) {
        _messages.add(Message(text: response, images: null, isFromUser: false));
        emit(ChatLoaded(List.from(_messages), isLoading: false));
      } else {
        emit(ChatError('No response from API.'));
        emit(ChatLoaded(List.from(_messages), isLoading: false));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
      emit(ChatLoaded(List.from(_messages), isLoading: false));
    }
  }

  Future<void> _onSendImagePrompt(
      SendImagePrompt event, Emitter<ChatState> emit) async {
    // imagePaths is a list of String image paths
    print('Image paths: ${event.imagePaths}');
    // Add user messages with images
    if (event.imagePaths.isEmpty) {
      _messages
          .add(Message(text: event.message, images: null, isFromUser: true));
    } else {
      _messages.add(Message(
        text: event.message,
        images: event.imagePaths,
        isFromUser: true,
      ));
    }
    emit(ChatLoaded(List.from(_messages), isLoading: true));
    try {
      // Call Repository to send image prompt and get response
      final response =
          await chatRepository.sendImagePrompt(event.message, event.imagePaths);

      // Save response to messages list
      if (response != null) {
        _messages.add(Message(text: response, images: null, isFromUser: false));
        emit(ChatLoaded(List.from(_messages), isLoading: false));
      } else {
        emit(ChatError('No response from API.'));
        emit(ChatLoaded(List.from(_messages), isLoading: false));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
      emit(ChatLoaded(List.from(_messages), isLoading: false));
    }
  }
}
