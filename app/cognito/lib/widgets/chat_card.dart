import 'package:cognito/utils/colors.dart';
import 'package:cognito/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatCard extends StatelessWidget {
  final String text;
  final bool isUser;
  const ChatCard({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final thinkEndIndex = text.indexOf('</think>');
    final hasThinking = thinkEndIndex != -1;
    final thinkingPart = hasThinking ? text.substring(0, thinkEndIndex) : null;
    final responsePart = hasThinking ? text.substring(thinkEndIndex + 8) : text;

    return Container(
      margin: isUser
          ? const EdgeInsets.only(left: 40, top: 5, bottom: 5, right: 5)
          : const EdgeInsets.only(right: 40, top: 5, bottom: 5, left: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.primaryColor,
        borderRadius: isUser
            ? const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              )
            : const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.3),
            blurRadius: 60,
          ),
        ],
      ),
      child: hasThinking
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (thinkingPart!.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.thinkingColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: MarkdownBody(
                      data: thinkingPart,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                if (responsePart.isNotEmpty)
                  MarkdownBody(
                    data: responsePart,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        color: AppColor.backgroundColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            )
          : MarkdownBody(
              data: text,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: AppColor.backgroundColor,
                  fontSize: 14,
                ),
              ),
            ),
    );
  }
}
