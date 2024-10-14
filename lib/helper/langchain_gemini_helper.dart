import 'dart:convert';

class LangChainGemini {
  static String getContent(String strData) {
    AIChatMessage message = AIChatMessage.fromString(strData);
    return message.content;
  }
}

// A defined class base on the LangChainGenimi API response, used to parse the response
class AIChatMessage {
  String content;
  List<dynamic> toolCalls;

  AIChatMessage({required this.content, required this.toolCalls});

  static AIChatMessage fromString(String response) {
    int startIndex = response.indexOf('{');
    int endIndex = response.lastIndexOf('}');
    if (startIndex == -1 || endIndex == -1) {
      throw Exception('Invalid input format');
    }

    String body = response.substring(startIndex + 1, endIndex).trim();

    List<String> properties =
        body.split('\n,\n').map((item) => item.trim()).toList();

    String content = '';
    List<dynamic> toolCalls = [];

    for (String property in properties) {
      if (property.startsWith('content:')) {
        content = property.substring('content:'.length).trim();
      } else if (property.startsWith('toolCalls:')) {
        String toolCallsString = property.substring('toolCalls:'.length).trim();
        if (toolCallsString.isNotEmpty) {
          toolCalls =
              toolCallsString.split(',').map((item) => item.trim()).toList();
        }
      }
    }

    return AIChatMessage(content: content, toolCalls: toolCalls);
  }
}
