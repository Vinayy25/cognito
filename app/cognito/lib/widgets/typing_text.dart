import 'package:flutter/material.dart';

class GPTTypingText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Duration speed;

  const GPTTypingText({
    Key? key,
    required this.text,
    this.textStyle =  const TextStyle(fontSize: 16.0, color: Colors.white),
    this.speed = const Duration(milliseconds: 50),
  }) : super(key: key);

  @override
  State<GPTTypingText> createState() => _GPTTypingTextState();
}

class _GPTTypingTextState extends State<GPTTypingText>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(
            milliseconds: widget.text.length * widget.speed.inMilliseconds));
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Opacity(
        opacity: _opacityAnim.value,
        child: Text(
          widget.text
              .substring(0, (_controller.value * widget.text.length).floor()),
          style: widget.textStyle,
        ),
      ),
    );
  }
}
