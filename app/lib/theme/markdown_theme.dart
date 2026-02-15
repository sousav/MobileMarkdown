import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

class MarkdownTheme {
  MarkdownTheme._();

  static MarkdownConfig lightConfig({ValueChanged<String>? onLinkTap}) {
    return MarkdownConfig(
      configs: [
        const PreConfig(
          decoration: BoxDecoration(
            color: Color(0xFFF6F8FA),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          textStyle: TextStyle(fontSize: 14, fontFamily: 'monospace'),
          padding: EdgeInsets.all(16.0),
          margin: EdgeInsets.symmetric(vertical: 8.0),
        ),
        const CodeConfig(
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'monospace',
            backgroundColor: Color(0xFFEFF1F3),
          ),
        ),
        const BlockquoteConfig(
          sideColor: Color(0xFF4A90D9),
          textColor: Color(0xFF57606A),
        ),
        TableConfig(
          border: TableBorder.all(color: const Color(0xFFD0D7DE)),
          headerRowDecoration: const BoxDecoration(color: Color(0xFFF6F8FA)),
          headerStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
        LinkConfig(
          style: const TextStyle(
            color: Color(0xFF0969DA),
            decoration: TextDecoration.underline,
          ),
          onTap: onLinkTap,
        ),
        const HrConfig(color: Color(0xFFD0D7DE), height: 1.5),
      ],
    );
  }

  static MarkdownConfig darkConfig({ValueChanged<String>? onLinkTap}) {
    return MarkdownConfig.darkConfig.copy(
      configs: [
        PreConfig.darkConfig.copy(
          decoration: const BoxDecoration(
            color: Color(0xFF2D2D2D),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          textStyle: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
        ),
        const CodeConfig(
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'monospace',
            backgroundColor: Color(0x44888888),
          ),
        ),
        const BlockquoteConfig(
          sideColor: Color(0xFF4A90D9),
          textColor: Color(0xFFD0D7DE),
        ),
        TableConfig(
          border: TableBorder.all(color: const Color(0xFF484F58)),
          headerRowDecoration: const BoxDecoration(color: Color(0xFF2D333B)),
          headerStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyStyle: const TextStyle(color: Color(0xFFADBACE)),
        ),
        LinkConfig(
          style: const TextStyle(
            color: Color(0xFF58A6FF),
            decoration: TextDecoration.underline,
          ),
          onTap: onLinkTap,
        ),
        const HrConfig(color: Color(0xFF484F58), height: 1.5),
      ],
    );
  }
}
