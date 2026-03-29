import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/file_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/recent_file_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileService _fileService = FileService();
  List<RecentFile> _recentFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();
  }

  Future<void> _loadRecentFiles() async {
    final files = await _fileService.getRecentFiles();
    if (mounted) {
      setState(() {
        _recentFiles = files;
        _isLoading = false;
      });
    }
  }

  Future<void> _openFilePicker() async {
    try {
      final result = await _fileService.pickFile();
      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) return;

      await _openFile(filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  Future<void> _openFile(String path) async {
    final fileName = path.split('/').last;

    try {
      // Check file size
      final fileSize = await _fileService.getFileSize(path);
      if (fileSize > maxFileSizeBytes && mounted) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Large File'),
            content: const Text(
              'This file is very large and may take a moment to load.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open Anyway'),
              ),
            ],
          ),
        );
        if (proceed != true) return;
      }

      final content = await _fileService.readFile(path);
      await _fileService.saveRecentFile(path, fileName);

      if (mounted) {
        await Navigator.pushNamed(
          context,
          '/view',
          arguments: {
            'content': content,
            'fileName': fileName,
            'filePath': path,
          },
        );
        // Refresh recents when returning
        _loadRecentFiles();
      }
    } on FileServiceException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
        if (e.type == FileServiceError.notFound) {
          await _fileService.removeRecentFile(path);
          _loadRecentFiles();
        }
      }
    }
  }

  Future<void> _removeRecentFile(RecentFile file) async {
    await _fileService.removeRecentFile(file.path);
    _loadRecentFiles();
  }

  Future<void> _openProjectPage() async {
    final uri = Uri.parse('https://github.com/sousav/MobileMarkdown');

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the GitHub repository')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the GitHub repository')),
        );
      }
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'MobileMarkdown',
      applicationVersion: '1.0.0',
      applicationLegalese: '\u00A9 2026',
      children: [
        const SizedBox(height: 16),
        const Text('A free, no-ads markdown viewer.'),
        const SizedBox(height: 8),
        const Text('Open source \u2014 MIT License'),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              _openProjectPage();
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('GitHub repository'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MobileMarkdown'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, semanticLabel: 'About'),
            tooltip: 'About',
            onPressed: _showAboutDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        const SizedBox(height: 24),
        // Open File button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FilledButton.icon(
            onPressed: _openFilePicker,
            icon: const Icon(Icons.folder_open),
            label: const Text('Open File'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Recent files or empty state
        Expanded(
          child: _recentFiles.isEmpty
              ? const EmptyState()
              : _buildRecentFilesList(),
        ),
      ],
    );
  }

  Widget _buildRecentFilesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Recent Files',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: _recentFiles.length,
            itemBuilder: (context, index) {
              final file = _recentFiles[index];
              return RecentFileTile(
                file: file,
                onTap: () => _openFile(file.path),
                onRemove: () => _removeRecentFile(file),
              );
            },
          ),
        ),
      ],
    );
  }
}
