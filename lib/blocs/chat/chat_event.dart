import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
}

class CreateNewChatSession extends ChatEvent {
  const CreateNewChatSession();

  @override
  List<Object> get props => [];
}

class SendTextMessage extends ChatEvent {
  final String message;

  const SendTextMessage(this.message);

  @override
  List<Object> get props => [message];
}

class SendImagePrompt extends ChatEvent {
  final String message;
  final List<String> imagePaths;

  const SendImagePrompt(this.message, this.imagePaths);

  @override
  List<Object> get props => [message, imagePaths];
}

class SaveChatSession extends ChatEvent {
  const SaveChatSession();

  @override
  List<Object> get props => [];
}

class LoadChatSession extends ChatEvent {
  final String sessionId;

  const LoadChatSession(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

class LoadSessionList extends ChatEvent {
  const LoadSessionList();

  @override
  List<Object> get props => [];
}

class LoadChatHistory extends ChatEvent {
  const LoadChatHistory();

  @override
  List<Object> get props => [];
}
