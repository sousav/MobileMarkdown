import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

class MarkdownTheme {
  MarkdownTheme._();

  static bool _isRemoteImage(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  static double? _parseDimension(String? value) {
    if (value == null) {
      return null;
    }

    return double.tryParse(value);
  }

  static Widget _buildImagePlaceholder({
    required String title,
    required String message,
    required bool isDark,
  }) {
    final backgroundColor = isDark
        ? const Color(0xFF2D333B)
        : const Color(0xFFF6F8FA);
    final borderColor = isDark
        ? const Color(0xFF444C56)
        : const Color(0xFFD0D7DE);
    final titleColor = isDark ? Colors.white : const Color(0xFF24292F);
    final messageColor = isDark
        ? const Color(0xFFADBACE)
        : const Color(0xFF57606A);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_not_supported_outlined, color: messageColor),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: TextStyle(color: titleColor, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4.0),
          Text(message, style: TextStyle(color: messageColor)),
        ],
      ),
    );
  }

  static Widget _buildImage(
    String url,
    Map<String, String> attributes, {
    required bool isDark,
  }) {
    final alt = attributes['alt'];
    final width = _parseDimension(attributes['width']);
    final height = _parseDimension(attributes['height']);

    if (_isRemoteImage(url)) {
      return _buildImagePlaceholder(
        title: alt?.isNotEmpty == true
            ? alt!
            : 'Remote image unavailable offline',
        message:
            'Remote image URLs are not fetched so the app stays fully offline.',
        isDark: isDark,
      );
    }

    return Image.asset(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildImagePlaceholder(
          title: alt?.isNotEmpty == true ? alt! : 'Image unavailable',
          message: 'This image source could not be loaded on this device.',
          isDark: isDark,
        );
      },
    );
  }

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
        ImgConfig(
          builder: (url, attributes) {
            return _buildImage(url, attributes, isDark: false);
          },
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
        ImgConfig(
          builder: (url, attributes) {
            return _buildImage(url, attributes, isDark: true);
          },
        ),
        const HrConfig(color: Color(0xFF484F58), height: 1.5),
      ],
    );
  }
}
