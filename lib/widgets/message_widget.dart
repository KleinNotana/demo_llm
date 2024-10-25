import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:typewritertext/typewritertext.dart';
import 'typing_indicator.dart';

class MessageWidget extends StatelessWidget {
  final List<String>? images;
  final String? text;
  final TypeWriterController stream;
  final bool isStreamData;
  final bool isFromUser;
  final bool isTyping;

  const MessageWidget({
    super.key,
    this.images,
    this.text,
    this.isStreamData = false,
    this.isTyping = false,
    required this.isFromUser,
    required this.stream,
  });

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
                  child: () {
                    if (isTyping) {
                      return const TypingIndicator(isFromUser: false);
                    } else {
                      if (isStreamData) {
                        return TypeWriter(
                          controller: stream,
                          builder: (context, value) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (text != null) ...[
                                  MarkdownBody(
                                    data: value.text,
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
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                            );
                          },
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                            if (images != null && images?.length != 0) ...[
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
                        );
                      }
                    }
                  }(),
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
