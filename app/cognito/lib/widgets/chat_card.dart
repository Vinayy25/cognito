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
    return Container(
      margin: (isUser == true)
          ? const EdgeInsets.only(left: 40, top: 5, bottom: 5, right: 5)
          : const EdgeInsets.only(right: 40, top: 5, bottom: 5, left: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.primaryColor,
        borderRadius: (isUser == true)
            ? BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              )
            : BorderRadius.only(
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
      child: AppText(
        text: text,
      ),
    );
  }
}
