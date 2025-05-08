import 'package:flutter/material.dart';

class QuestionButton extends StatefulWidget {
  final int number;
  final bool isHighlighted;

  const QuestionButton({
    Key? key,
    required this.number,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  _QuestionButtonState createState() => _QuestionButtonState();
}

class _QuestionButtonState extends State<QuestionButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: widget.isHighlighted
            ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9E8CC1), Color(0xFFCAB8E8)],
        )
            : null,
        color: widget.isHighlighted ? null : Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info,
            color: widget.isHighlighted ? Colors.white : Colors.grey,
            size: 18,
          ),
          const SizedBox(height: 4),
          Text(
            widget.number.toString(),
            style: TextStyle(
              color: widget.isHighlighted ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}