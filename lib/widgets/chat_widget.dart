import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'message_widget.dart';
import 'typing_indicator.dart';
import '../models/message.dart';

import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import '../blocs/chat/chat_state.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({Key? key}) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final ImagePicker _picker = ImagePicker();
  List<String> _imagePaths = [];
  bool _needToResetImage = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _textFieldFocus.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  void _sendChatMessage(String message) {
    if (message.trim().isEmpty) return;
    context.read<ChatBloc>().add(SendTextMessage(message));
    _textController.clear();
    _textFieldFocus.requestFocus();
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _imagePaths = images.map((image) => image.path).toList();
        _needToResetImage = false;
      });
      _scrollDown();
    }
  }

  void _sendImagePrompt(String message, List<String> imagePaths) {
    if (message.trim().isEmpty) {
      message = 'Describe the image(s)';
    }
    print('Image paths in _sendImagePrompt: $imagePaths');
    context.read<ChatBloc>().add(SendImagePrompt(message, imagePaths));
    _textController.clear();
    _textFieldFocus.requestFocus();
    setState(() {
      _imagePaths = [];
      _needToResetImage = true;
    });
  }

  Null Function() _handleCopyMessage(Message message) {
    return () {
      if (message.text != null) {
        Clipboard.setData(ClipboardData(text: message.text ?? ''));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copied to clipboard'),
            duration: Duration(milliseconds: 500),
          ),
        );
      }
    };
  }

  Null Function() _handleRegenerateMessage(Message? reMessage) {
    return () {
      if (reMessage != null) {
        context.read<ChatBloc>().add(SendImagePrompt(
          reMessage.text ?? 'Describe the image(s)',
          reMessage.images ?? [],
        ));

        _scrollDown();
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    const textFieldDecoration = InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      hintText: 'Enter a prompt...',
      // hide the border
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide.none,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded) {
                  _scrollDown();
                } else if (state is ChatError) {
                  _showError(state.error);
                }
              },
              builder: (context, state) {
                List<Message> messages = [];
                bool isLoading = false;

                if (state is ChatInitial) {
                  return const Center(
                      child: Text(
                        'Start Chatting',
                        style: TextStyle(fontSize: 20),
                      ));
                } else if (state is ChatLoaded) {
                  messages = state.messages;
                  isLoading = state.isLoading;
                } else if (state is ChatError) {
                  // In case of error, still show existing messages
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, idx) {
                    if (idx < messages.length) {
                      final message = messages[idx];
                      final previousMessage =
                      idx > 0 ? messages[idx - 1] : null;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MessageWidget(
                            text: message.text,
                            images: message.images,
                            isFromUser: message.isFromUser,
                          ),
                          if (!message.isFromUser)
                            Container(
                              margin: const EdgeInsets.only(left: 5, top: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    onPressed: _handleCopyMessage(message),
                                    icon: const Icon(
                                      Icons.copy,
                                      color: Color(0xfffbfbfb),
                                      size: 15,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _handleRegenerateMessage(
                                        previousMessage),
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Color(0xfffbfbfb),
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    } else {
                      // Display TypingIndicator at the end of the list
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: TypingIndicator(),
                      );
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: !_needToResetImage && _imagePaths.isNotEmpty
                ? SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _imagePaths.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(
                        _imagePaths[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                          : Image.file(
                        File(_imagePaths[index]),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            )
                : const SizedBox.shrink(),
          ),
          Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2f2f2f),
                borderRadius: BorderRadius.circular(90),
                border: Border.all(
                  color: const Color(0xFF2f2f2f),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _pickImages,
                      icon: const Icon(
                        Icons.image,
                        color: Color(0xfffbfbfb),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        focusNode: _textFieldFocus,
                        decoration: textFieldDecoration,
                        controller: _textController,
                        onSubmitted: _sendChatMessage,
                        cursorColor: const Color(0xfffbfbfb),
                      ),
                    ),
                    BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        bool isLoading = false;
                        if (state is ChatLoaded) {
                          isLoading = state.isLoading;
                        } else if (state is ChatInitial) {
                          isLoading = false;
                        } else if (state is ChatError) {
                          isLoading = false;
                        }
                        if (isLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return IconButton(
                          onPressed: () {
                            if (_imagePaths.isNotEmpty) {
                              print('Image paths after click: $_imagePaths');
                              _sendImagePrompt(
                                  _textController.text, _imagePaths);
                            } else {
                              _sendChatMessage(_textController.text);
                            }
                            _textFieldFocus.unfocus();
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Color(0xfffbfbfb),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }
}
