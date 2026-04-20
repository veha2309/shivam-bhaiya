import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/services/download_service.dart';
import 'package:permission_handler/permission_handler.dart';

class GenericWebViewScreen extends StatefulWidget {
  final String? title;
  final String url;
  const GenericWebViewScreen({super.key, this.title, required this.url});

  @override
  State<GenericWebViewScreen> createState() => _GenericWebViewScreenState();
}

class _GenericWebViewScreenState extends State<GenericWebViewScreen> {
  InAppWebViewController? webViewController;
  bool _isLoading = true;
  double _progress = 0;
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final List<Permission> permissionsToRequest = [
      Permission.camera,
      Permission.photos,
      Permission.storage,
    ];
    await permissionsToRequest.request();
    final cameraGranted = await Permission.camera.isGranted;
    final storageGranted = await Permission.photos.isGranted || await Permission.storage.isGranted;
    setState(() { _permissionsGranted = cameraGranted && storageGranted; });
  }

  Uri buildWebViewUri(String baseUrl, Map<String, String> params) {
    final uri = Uri.parse(baseUrl);
    final newParams = Map<String, String>.from(uri.queryParameters)..addAll(params);
    return uri.replace(queryParameters: newParams);
  }

  @override
  Widget build(BuildContext context) {
    User? user = AuthViewModel.instance.getLoggedInUser();
    Map<String, String> params = {
      "username": user?.username ?? "",
      "userType": "Student",
      "affiliationCode": user?.affiliationCode ?? "",
      "V1": user?.username ?? "",
    };

    Uri url = buildWebViewUri(widget.url, params);

    return AppScaffold(
      body: AppBody(
        title: widget.title ?? 'WebView',
        body: Container(
          color: Colors.grey[100], // Subtle background for web "canvas" feel
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200), // Max width for Web
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    // --- Modern Browser-like Toolbar ---
                    _buildWebToolbar(),

                    // --- Progress Bar ---
                    if (_progress < 1.0)
                      LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.transparent,
                        color: Theme.of(context).primaryColor,
                        minHeight: 3,
                      ),

                    // --- WebView Content ---
                    Expanded(
                      child: Stack(
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
                              iframeAllow: "camera; microphone",
                              iframeAllowFullscreen: true,
                              supportMultipleWindows: true,
                              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                              domStorageEnabled: true,
                              useHybridComposition: true,
                            ),
                            onWebViewCreated: (controller) => webViewController = controller,
                            onProgressChanged: (controller, progress) {
                              setState(() { _progress = progress / 100; });
                            },
                            onPermissionRequest: (controller, request) async {
                              return PermissionResponse(
                                resources: request.resources,
                                action: PermissionResponseAction.GRANT,
                              );
                            },
                            onLoadStart: (controller, url) => setState(() => _isLoading = true),
                            onLoadStop: (controller, url) async {
                              setState(() => _isLoading = false);
                              _injectFileUploadFix(controller);
                            },
                            shouldOverrideUrlLoading: (controller, navigationAction) async {
                              final url = navigationAction.request.url.toString();
                              if (DownloadService.isDownloadableUrl(url)) {
                                await DownloadService.downloadFile(url: url, context: context);
                                return NavigationActionPolicy.CANCEL;
                              }
                              return NavigationActionPolicy.ALLOW;
                            },
                            onDownloadStartRequest: (controller, url) async {
                              await DownloadService.downloadFile(
                                url: url.url.toString(),
                                context: context,
                                fileName: getFileNameFromUrl(url.url),
                              );
                            },
                          ),
                          if (_isLoading && _progress < 0.1)
                            Center(child: CircularProgressIndicator()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebToolbar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => webViewController?.goBack(),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed: () => webViewController?.goForward(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () => webViewController?.reload(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, size: 14, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.url,
                      style: const TextStyle(fontSize: 12, color: Colors.grey, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Future<void> _injectFileUploadFix(InAppWebViewController controller) async {
    final acceptValue = Platform.isIOS ? 'image/jpeg,image/png' : 'image/*';
    await controller.evaluateJavascript(source: """
      (function() {
        var fileInputs = document.querySelectorAll('input[type="file"]');
        fileInputs.forEach(function(input) {
          if (!input.hasAttribute('accept')) { input.setAttribute('accept', '$acceptValue'); }
          if (input.hasAttribute('capture')) { input.removeAttribute('capture'); }
        });
      })();
    """);
  }
}

String getFileNameFromUrl(Uri uri) {
  try {
    final jrxmlPath = uri.queryParameters['jrxmlPath'];
    if (jrxmlPath == null || jrxmlPath.isEmpty) throw Exception();
    return jrxmlPath.split('/').last;
  } catch (e) {
    return "${DateTime.now().millisecondsSinceEpoch}";
  }
}