import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';

class ReadMorePopupText extends StatefulWidget {
  final String heading;
  final String text;
  final VoidCallback? onCancel;

  const ReadMorePopupText(
      {super.key, required this.heading, required this.text, this.onCancel});

  @override
  State<ReadMorePopupText> createState() => _ReadMorePopupTextState();
}

class _ReadMorePopupTextState extends State<ReadMorePopupText> {
  bool _isTextOverflowing = false;
  final int maxLines = 5;

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to check overflow
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(
          text: widget.text,
          style: const TextStyle(fontSize: 16),
        );
        final tp = TextPainter(
          text: span,
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        );
        tp.layout(maxWidth: constraints.maxWidth);

        _isTextOverflowing = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: Html(
                data: widget.text,
                style: {
                  "*": Style(
                    fontSize: FontSize(16),
                    maxLines: maxLines,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                },
                extensions: const [
                  TableHtmlExtension(),
                ],
              ),
            ),
            if (_isTextOverflowing)
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => _showFullTextDialog(context),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Read more',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showFullTextDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(widget.heading),
        content: SingleChildScrollView(
          child: Html(
            data: widget.text,
            style: {
              "*": Style(fontSize: FontSize(16)),
            },
            extensions: const [
              TableHtmlExtension(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onCancel?.call();
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
