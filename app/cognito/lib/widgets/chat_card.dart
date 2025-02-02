import 'package:cognito/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatCard extends StatefulWidget {
  final String text;
  final bool isUser;

  const ChatCard({super.key, required this.text, required this.isUser});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  bool _showThinking = false;

  @override
  Widget build(BuildContext context) {
    // Extract thinking and response parts
    final thinkEndIndex = widget.text.indexOf('</think>');
    final hasThinking = thinkEndIndex != -1;
    final thinkingPart =
        hasThinking ? widget.text.substring(0, thinkEndIndex).trim() : null;
    final responsePart =
        hasThinking ? widget.text.substring(thinkEndIndex + 8) : widget.text;

    return Container(
      margin: widget.isUser
          ? const EdgeInsets.only(left: 40, top: 5, bottom: 5, right: 5)
          : const EdgeInsets.only(right: 40, top: 5, bottom: 5, left: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.primaryColor,
        borderRadius: widget.isUser
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show Thinking Process Section (if applicable)
          if (hasThinking && thinkingPart!.isNotEmpty) ...[
            // Modern Toggle Button
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => _showThinking = !_showThinking),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.thinkingColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showThinking
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColor.thinkingColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _showThinking ? 'Hide' : 'Show',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Animated Thinking Section
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _showThinking
                  ? Container(
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: AppColor.thinkingColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: MarkdownBody(
                        data: thinkingPart!,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            color: Colors.black.withOpacity(0.8),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],

          // Always Visible Response
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: MarkdownBody(
              data: responsePart,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: AppColor.backgroundColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
