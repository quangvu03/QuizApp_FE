import 'package:flutter/material.dart';

class QuestionButton extends StatefulWidget {
  final int number;
  final bool isHighlighted;
  final String status; // 'correct', 'incorrect', 'unanswered'
  final Color borderColor;
  final VoidCallback? onTap;

  const QuestionButton({
    Key? key,
    required this.number,
    this.isHighlighted = false,
    required this.status,
    required this.borderColor,
    this.onTap,
  }) : super(key: key);

  @override
  _QuestionButtonState createState() => _QuestionButtonState();
}

class _QuestionButtonState extends State<QuestionButton> {
  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    switch (widget.status) {
      case 'correct':
        icon = Icons.check;
        iconColor = widget.isHighlighted ? Colors.white : Colors.green;
        break;
      case 'incorrect':
        icon = Icons.close;
        iconColor = widget.isHighlighted ? Colors.white : Colors.red;
        break;
      case 'unanswered':
      default:
        icon = Icons.info;
        iconColor = widget.isHighlighted ? Colors.white : Colors.grey;
        break;
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
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
          border: Border.all(color: widget.borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
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
      ),
    );
  }
}