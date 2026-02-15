import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../theme/markdown_theme.dart';

/// Arguments passed to ViewerScreen via navigation.
class ViewerArgs {
  final String content;
  final String fileName;
  final String? filePath;
  final String? errorMessage;

  const ViewerArgs({
    required this.content,
    required this.fileName,
    this.filePath,
    this.errorMessage,
  });
}

class ViewerScreen extends StatefulWidget {
  final String markdownContent;
  final String fileName;
  final String? filePath;
  final String? errorMessage;

  const ViewerScreen({
    super.key,
    required this.markdownContent,
    required this.fileName,
    this.filePath,
    this.errorMessage,
  });

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  bool _showScrollToTop = false;
  final _tocController = TocController();

  @override
  void dispose() {
    _tocController.dispose();
    super.dispose();
  }

  Future<void> _handleLinkTap(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open: $url')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open: $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName,
          overflow: TextOverflow.ellipsis,
          semanticsLabel: 'File: ${widget.fileName}',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              themeController.themeIcon,
              semanticLabel: themeController.themeLabel,
            ),
            tooltip: themeController.themeLabel,
            onPressed: () => themeController.cycleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.share, semanticLabel: 'Share file'),
            tooltip: 'Share file',
            onPressed: _shareFile,
          ),
        ],
      ),
      body: _buildBody(isDark),
      floatingActionButton: AnimatedScale(
        scale: _showScrollToTop ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton.small(
          onPressed: _scrollToTop,
          tooltip: 'Scroll to top',
          child: const Icon(Icons.arrow_upward, semanticLabel: 'Scroll to top'),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    // Error state
    if (widget.errorMessage != null) {
      return _buildErrorState(widget.errorMessage!);
    }

    // Empty file state
    if (widget.markdownContent.isEmpty) {
      return _buildErrorState('This file is empty');
    }

    final config = isDark
        ? MarkdownTheme.darkConfig(onLinkTap: _handleLinkTap)
        : MarkdownTheme.lightConfig(onLinkTap: _handleLinkTap);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final shouldShow = notification.metrics.pixels > 500;
          if (shouldShow != _showScrollToTop) {
            setState(() {
              _showScrollToTop = shouldShow;
            });
          }
        }
        return false;
      },
      child: MarkdownWidget(
        data: widget.markdownContent,
        config: config,
        tocController: _tocController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
              semanticLabel: 'Error',
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.folder_open),
              label: const Text('Open Another File'),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToTop() {
    _tocController.jumpToIndex(0);
  }

  Future<void> _shareFile() async {
    final path = widget.filePath;

    if (path != null && await File(path).exists()) {
      // Share the original file via platform share sheet
      try {
        if (Platform.isAndroid) {
          // Use Android intent via method channel
          const channel = MethodChannel('com.mobilemarkdown/share');
          await channel.invokeMethod('shareFile', {'path': path});
          return;
        } else if (Platform.isIOS) {
          const channel = MethodChannel('com.mobilemarkdown/share');
          await channel.invokeMethod('shareFile', {'path': path});
          return;
        }
      } on MissingPluginException {
        // Platform channel not implemented; fall through to clipboard
      } catch (_) {
        // Fall through to clipboard fallback
      }
    }

    // Fallback: copy content to clipboard
    if (widget.markdownContent.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: widget.markdownContent));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content copied to clipboard')),
        );
      }
    }
  }
}
