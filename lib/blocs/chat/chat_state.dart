import 'package:equatable/equatable.dart';
import '../../../models/message.dart';
import '../../models/chat_session.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  final List<ChatSession> chatSessions;
  final bool isLoading;

  const ChatLoaded(
    this.messages, {
    List<ChatSession>? chatSessions,
    this.isLoading = false,
  }) : chatSessions = chatSessions ?? const [];

  ChatLoaded copyWith({
    List<Message>? messages,
    List<ChatSession>? chatSessions,
    bool? isLoading,
  }) {
    return ChatLoaded(
      messages ?? this.messages,
      chatSessions: chatSessions ?? this.chatSessions,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [messages, chatSessions, isLoading];
}

class ChatError extends ChatState {
  final String error;

  const ChatError(this.error);

  @override
  List<Object?> get props => [error];
}
