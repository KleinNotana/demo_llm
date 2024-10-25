class Message {
  late String? text;
  final List<String>? images;
  final bool isFromUser;

  Message({this.text, this.images, required this.isFromUser});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'],
      images: List<String>.from(json['images']),
      isFromUser: json['isFromUser'],
    );
  }

  Map<String, dynamic> toJson() {
    if (images == null || images!.isEmpty) {
      return {
        'text': text,
        'images': [],
        'isFromUser': isFromUser,
      };
    }

    return {
      'text': text,
      'images': List<dynamic>.from(images!.map((x) => x)),
      'isFromUser': isFromUser,
    };
  }
}
