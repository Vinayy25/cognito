import 'package:cognito/utils/text.dart';
import 'package:flutter/material.dart';

class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: AppText(text: "Cognito"),
        )
      ],
    );
  }
}
