import 'package:cognito/utils/colors.dart';
import 'package:cognito/utils/text.dart';
import 'package:flutter/material.dart';

class WelcomeMessage extends StatelessWidget {
  const WelcomeMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Column(
        children: [
          AppText(
              text: "Hello, Ask me",
              fontsize: 25,
              color: AppColor.primaryTextColor),
          AppText(
              text: "Anything you want",
              fontsize: 17,
              color: AppColor.secondaryTextColor),
        ],
      ),
    );
  }
}
