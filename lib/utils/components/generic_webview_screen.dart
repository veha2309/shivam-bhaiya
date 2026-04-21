import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/services/download_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:school_app/utils/language_provider.dart';
import 'package:provider/provider.dart';

class GenericWebViewScreen extends StatefulWidget {
  final String? title;
  final String url;
  const GenericWebViewScreen({super.key, this.title, required this.url});

  @override
  State<GenericWebViewScreen> createState() => _GenericWebViewScreenState();
}

class _GenericWebViewScreenState extends State<GenericWebViewScreen> {
  bool _isLoading = true;
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request camera and storage permissions for file upload with camera option.
    // permission_handler v11 automatically maps Permission.photos to
    // READ_MEDIA_IMAGES on Android 13+ and READ_EXTERNAL_STORAGE on older APIs.
    // Permission.mediaLibrary does NOT exist on Android — remove it.
    final List<Permission> permissionsToRequest = [
      Permission.camera,
      Permission.photos,
      Permission.storage,
    ];

    await permissionsToRequest.request();

    // Consider granted if camera + at least one storage permission is granted.
    final cameraGranted = await Permission.camera.isGranted;
    final storageGranted = await Permission.photos.isGranted ||
        await Permission.storage.isGranted;
    final allGranted = cameraGranted && storageGranted;

    setState(() {
      _permissionsGranted = allGranted;
    });

    if (!allGranted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Camera and storage permissions are required for uploading images',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Uri buildWebViewUri(String baseUrl, Map<String, String> params) {
    final uri = Uri.parse(baseUrl);
    final newParams = Map<String, String>.from(uri.queryParameters)
      ..addAll(params);
    return uri.replace(queryParameters: newParams);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    User? user = AuthViewModel.instance.getLoggedInUser();
    String affiliationCode = user?.affiliationCode ?? "";

    Map<String, String> params = {
      "username": user?.username ?? "",
      "userType": "Student",
      "affiliationCode": affiliationCode,
      "V1": user?.username ?? "",
    };

    Uri url = buildWebViewUri(widget.url, params);

    return AppScaffold(
      body: AppBody(
        title: context.read<LanguageProvider>().translate(widget.title ?? 'Website'),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri.uri(url)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useOnDownloadStart: true,
                useOnLoadResource: true,
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                allowFileAccessFromFileURLs: true,
                allowUniversalAccessFromFileURLs: true,
                javaScriptCanOpenWindowsAutomatically: true,
                allowContentAccess: true,
                allowFileAccess: true,
                // Enable media capture support
                iframeAllow: "camera; microphone",
                iframeAllowFullscreen: true,
                // Additional settings for file input and camera
                supportMultipleWindows: true,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                // Android-specific settings for camera/file upload
                domStorageEnabled: true,
                databaseEnabled: true,
                cacheEnabled: true,
                // Critical for file uploads
                useHybridComposition: true,
              ),
              onWebViewCreated: (controller) {
                // Enable console logging for debugging
                controller.addJavaScriptHandler(
                  handlerName: 'consoleLog',
                  callback: (args) {
                    print('WebView Console: $args');
                  },
                );
              },
              onConsoleMessage: (controller, consoleMessage) {
                print(
                  'WebView Console [${consoleMessage.messageLevel}]: ${consoleMessage.message}',
                );
              },
              onPermissionRequest: (controller, request) async {
                // Grant permission for camera and other media resources
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT,
                );
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _isLoading = true;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  _isLoading = false;
                });

                final acceptValue =
                    Platform.isIOS ? 'image/jpeg,image/png' : 'image/*';

                // Inject JavaScript to monitor file inputs.
                // NOTE: We intentionally do NOT set capture="environment" on Android.
                // That attribute forces a direct camera launch, bypassing the native
                // file chooser (Photo Library / Take Photo / Choose File) entirely.
                // On newer Android WebView versions this causes the picker to silently
                // disappear. Let the website's own HTML decide the capture mode.
                await controller.evaluateJavascript(
                  source: """
                  (function() {
                    var fileInputs = document.querySelectorAll('input[type="file"]');
                    fileInputs.forEach(function(input) {
                      console.log('Found file input:', input);

                      // Add change listener for debugging
                      input.addEventListener('change', function(e) {
                        console.log('File input changed!');
                        console.log('Files selected:', e.target.files.length);
                        if (e.target.files.length > 0) {
                          console.log('File name:', e.target.files[0].name);
                          console.log('File size:', e.target.files[0].size);
                          console.log('File type:', e.target.files[0].type);
                        }
                      });

                      // Only set accept if the website hasn't already specified one
                      if (!input.hasAttribute('accept')) {
                        input.setAttribute('accept', '$acceptValue');
                      }

                      // Always remove any existing capture attribute on Android so
                      // the full file chooser (gallery + camera + files) is shown.
                      if (input.hasAttribute('capture')) {
                        input.removeAttribute('capture');
                      }
                    });

                    console.log('File input monitoring initialized. Found ' + fileInputs.length + ' file inputs.');
                  })();
                """,
                );
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url.toString();

                // Check if URL is downloadable
                if (DownloadService.isDownloadableUrl(url)) {
                  // Handle download
                  await DownloadService.downloadFile(
                    url: url,
                    context: context,
                  );
                  // Prevent navigation to download URL
                  return NavigationActionPolicy.CANCEL;
                }

                // Allow normal navigation
                return NavigationActionPolicy.ALLOW;
              },
              onDownloadStartRequest: (controller, url) async {
                String uuid = getFileNameFromUrl(url.url);
                // Handle download requests
                await DownloadService.downloadFile(
                  url: url.url.toString(),
                  context: context,
                  fileName: uuid,
                );
              },
              onReceivedError: (controller, request, error) {
                setState(() {
                  _isLoading = false;
                });
              },
            ),
            if (_isLoading) Center(child: getLoaderWidget()),
          ],
        ),
      ),
    );
  }
}

String getFileNameFromUrl(Uri uri) {
  try {
    // Get the jrxmlPath query parameter
    final jrxmlPath = uri.queryParameters['jrxmlPath'];

    if (jrxmlPath == null || jrxmlPath.isEmpty) {
      throw Exception('jrxmlPath parameter not found');
    }

    // Extract filename from the path
    final fileName = jrxmlPath.split('/').last;

    if (fileName.isEmpty) {
      throw Exception('Filename is empty');
    }

    return fileName;
  } catch (e) {
    // Fallback to UUID
    String uuid = "${DateTime.now().millisecondsSinceEpoch}";
    return uuid;
  }
}