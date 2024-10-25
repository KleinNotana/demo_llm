import 'message.dart';

class ChatSession {
  late final String id;
  List<Message> messages;

  ChatSession({required this.id, required this.messages});

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      messages:
          List<Message>.from(json['messages'].map((x) => Message.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    if (messages == null || messages.isEmpty) {
      return {
        'id': id,
        'messages': [],
      };
    }

    return {
      'id': id,
      'messages': List<dynamic>.from(messages.map((x) => x.toJson())),
    };
  }
}
