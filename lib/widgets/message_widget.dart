import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'typing_indicator.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    Key? key,
    this.images,
    this.text,
    this.isTyping = false,
    required this.isFromUser,
  }) : super(key: key);

  final List<String>? images;
  final String? text;
  final bool isFromUser;
  final bool isTyping;

  @override
  Widget build(BuildContext context) {
    final double paddingLeft = isFromUser ? 40 : 0;
    return Padding(
      padding: EdgeInsets.fromLTRB(paddingLeft, 0, 0, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  decoration: BoxDecoration(
                    color: isFromUser
                        ? const Color(0xFF2F2F2F)
                        : const Color(0x00000000),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  child: isTyping
                      ? const TypingIndicator(isFromUser: false)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (text != null) ...[
                              MarkdownBody(
                                data: text!,
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                            // images is a list of image string file paths, not assets
                            if (images != null) ...[
                              SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: images!.map((image) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: FileImage(File(image)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 10),
                            ],
                          ],
                        ),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }
}
