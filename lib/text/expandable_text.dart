import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;

  const ExpandableText({
    super.key,
    required this.text,
    this.maxLines = 3,
    this.style,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = GoogleFonts.poppins(
      fontSize: 14,
      color: const Color(0xFF4A5568),
      height: 1.4,
    );
    
    // Don't show expand/collapse if text is short enough
    if (_getTextLines(widget.text, widget.style ?? defaultStyle, MediaQuery.of(context).size.width - 60) <= widget.maxLines) {
      return Text(
        widget.text,
        style: widget.style ?? defaultStyle,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: widget.style ?? defaultStyle,
          maxLines: _isExpanded ? null : widget.maxLines,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Text(
            _isExpanded ? 'Show less' : 'Read more',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF667eea),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to estimate number of lines (approximate)
  int _getTextLines(String text, TextStyle style, double maxWidth) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1000, // arbitrary large number
    )..layout(maxWidth: maxWidth);
    
    return textPainter.computeLineMetrics().length;
  }
}