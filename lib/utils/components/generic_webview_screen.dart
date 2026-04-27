import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/services/download_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';

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
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      List<Permission> permissionsToRequest = [Permission.camera];

      if (sdkInt < 33) {
        // Android 12 and below
        permissionsToRequest.add(Permission.storage);
      }
      // On Android 13+, we don't request Permission.photos or Permission.videos
      // because we use the system Photo Picker via InAppWebView, which requires no permissions.

      final statuses = await permissionsToRequest.request();

      bool cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
      bool storageGranted = sdkInt < 33 ? (statuses[Permission.storage]?.isGranted ?? false) : true;

      setState(() {
        _permissionsGranted = cameraGranted && storageGranted;
      });

      if (!cameraGranted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required for taking photos'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      // iOS and other platforms
      final statuses = await [
        Permission.camera,
        Permission.photos,
      ].request();

      setState(() {
        _permissionsGranted = statuses[Permission.camera]?.isGranted == true &&
            statuses[Permission.photos]?.isGranted == true;
      });
    }
  }

  Uri buildWebViewUri(String baseUrl, Map<String, String> params) {
    final uri = Uri.parse(baseUrl);
    final newParams = Map<String, String>.from(uri.queryParameters)..addAll(params);
    return uri.replace(queryParameters: newParams);
  }

  // Helper function to check if a scheme is a standard web scheme
  bool _isStandardWebScheme(String? scheme) {
    if (scheme == null) return true;
    final s = scheme.toLowerCase();
    return ['http', 'https', 'file', 'chrome', 'data', 'javascript', 'about'].contains(s);
  }

  @override
  Widget build(BuildContext context) {
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
        title: widget.title ?? 'WebView',
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
                iframeAllow: "camera; microphone",
                iframeAllowFullscreen: true,
                supportMultipleWindows: true,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                domStorageEnabled: true,
                databaseEnabled: true,
                cacheEnabled: true,
                useHybridComposition: true,
              ),
              onLoadStart: (controller, url) async {
                // SAFEGUARD 1: If it's not a standard web link, stop the engine immediately
                if (!_isStandardWebScheme(url?.scheme)) {
                  controller.stopLoading();
                  return;
                }

                setState(() {
                  _isLoading = true;
                });
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final uri = navigationAction.request.url;
                if (uri == null) return NavigationActionPolicy.ALLOW;

                // 1. Handle normal web navigation
                if (_isStandardWebScheme(uri.scheme)) {
                  if (DownloadService.isDownloadableUrl(uri.toString())) {
                    await DownloadService.downloadFile(
                      url: uri.toString(),
                      context: context,
                    );
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.ALLOW;
                }

                // 2. Handle ALL custom schemes (upi://, gpay://, phonepe://, intent://, etc.)
                controller.stopLoading(); // Tell webview to halt

                try {
                  bool launched = await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );

                  if (!launched && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("The selected payment app is not installed on this device."),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint("Error launching deep link: $e");
                }

                return NavigationActionPolicy.CANCEL;
              },
              onReceivedError: (controller, request, error) async {
                setState(() {
                  _isLoading = false;
                });

                // SAFEGUARD 2: The ultimate fallback.
                // If Android ignored our cancel request and showed the error anyway,
                // we instantly force the WebView to go back to the checkout page.
                if (error.description == "net::ERR_UNKNOWN_URL_SCHEME") {
                  debugPrint("Caught ERR_UNKNOWN_URL_SCHEME. Forcing UI back to Razorpay.");
                  if (await controller.canGoBack()) {
                    await controller.goBack();
                  }
                }
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  _isLoading = false;
                });

                // ... (Keep your existing JavaScript injection for the camera here) ...
              },
              onDownloadStartRequest: (controller, url) async {
                String uuid = getFileNameFromUrl(url.url);
                await DownloadService.downloadFile(
                  url: url.url.toString(),
                  context: context,
                  fileName: uuid,
                );
              },
            ),
            if (_isLoading) Center(child: const CircularProgressIndicator()), // Assuming you have a loader
          ],
        ),
      ),
    );
  }
}

String getFileNameFromUrl(Uri uri) {
  try {
    final jrxmlPath = uri.queryParameters['jrxmlPath'];
    if (jrxmlPath == null || jrxmlPath.isEmpty) throw Exception('jrxmlPath parameter not found');
    final fileName = jrxmlPath.split('/').last;
    if (fileName.isEmpty) throw Exception('Filename is empty');
    return fileName;
  } catch (e) {
    return "${DateTime.now().millisecondsSinceEpoch}";
  }
}