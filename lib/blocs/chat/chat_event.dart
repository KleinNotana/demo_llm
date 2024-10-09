import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
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
