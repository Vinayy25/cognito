import 'package:cognito/utils/colors.dart';
import 'package:cognito/utils/text.dart';
import 'package:flutter/cupertino.dart';

class SquareBoxDesign extends StatelessWidget {
  final String text;
  const SquareBoxDesign({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          color: AppColor.backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.fromBorderSide(BorderSide(
            color: AppColor.primaryTextColor,
            width: 0.25,
          )),
          boxShadow: [
            BoxShadow(
                color: AppColor.primaryTextColor,
                blurRadius: 5,
                spreadRadius: 1)
          ]),
      child: AppText(text: text, color: AppColor.primaryTextColor),
    );
  }
}
