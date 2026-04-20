import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  static const List<String> downloadableExtensions = [
    '.pdf',
    '.doc',
    '.docx',
    '.xls',
    '.xlsx',
    '.ppt',
    '.pptx',
    '.zip',
    '.rar',
    '.txt',
    '.csv',
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.mp4',
    '.mp3',
    '.avi',
    '.mov'
  ];

  /// Check if URL is a downloadable file
  static bool isDownloadableUrl(String url) {
    final uri = Uri.parse(url.toLowerCase());
    final path = uri.path.toLowerCase();

    // Check for direct file extensions
    for (String extension in downloadableExtensions) {
      if (path.endsWith(extension)) {
        return true;
      }
    }

    // Check for common download indicators in query parameters
    final queryParams = uri.queryParameters;
    if (queryParams.containsKey('download') ||
        queryParams.containsKey('attachment') ||
        queryParams.containsKey('export')) {
      return true;
    }

    // Check for Content-Disposition header indicators in URL patterns
    if (path.contains('/download/') ||
        path.contains('/export/') ||
        path.contains('/attachment/')) {
      return true;
    }

    return false;
  }

  /// Download file from URL
  static Future<String?> downloadFile({
    required String url,
    required BuildContext context,
    String? fileName,
  }) async {
    try {
      // Get download directory (use app external storage directory)
      Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir == null) {
        _showSnackBar(context, 'Could not access download directory');
        return null;
      }

      // Generate filename if not provided
      if (fileName == null || fileName.isEmpty) {
        final uri = Uri.parse(url);
        fileName =
            uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'download';
        if (!fileName.contains('.')) {
          fileName += '.pdf'; // Default extension
        }
      }

      // Ensure filename is safe for file system
      fileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

      // Show download started message
      _showSnackBar(context, 'Download started: $fileName');

      // Start download using FlutterDownloader with additional error handling
      try {
        final taskId = await FlutterDownloader.enqueue(
          url: url.toString(),
          savedDir: externalDir.path,
          fileName: fileName,
          showNotification: true, // Show download notification
          openFileFromNotification:
              true, // Open file when notification is tapped
        );

        if (taskId != null) {
          _showSnackBar(context, 'Download will continue in background');
        } else {
          _showSnackBar(context, 'Failed to start download');
        }

        return taskId;
      } catch (downloaderError) {
        print('FlutterDownloader error: $downloaderError');
        _showSnackBar(context, 'Download service not available');
        return null;
      }
    } catch (e) {
      _showSnackBar(context, 'Download failed: ${e.toString()}');
      return null;
    }
  }

  /// Show snackbar message
  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Initialize download service
  static Future<void> initialize() async {
    try {
      // Initialize FlutterDownloader with minimal configuration
      await FlutterDownloader.initialize(
        debug: false,
        ignoreSsl: false,
      );

      // Register callback after successful initialization
      await FlutterDownloader.registerCallback(downloadCallback);

      print('FlutterDownloader initialized successfully');
    } catch (e) {
      print('Error initializing FlutterDownloader: $e');
      // Don't rethrow the error to prevent app crash
    }
  }

  /// Download progress callback
  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    // Handle download progress updates
    print('Download $id: status=$status, progress=$progress');
  }
}
