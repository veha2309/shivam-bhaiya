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
    final permissions = await [
      Permission.camera,
      Permission.photos,
      Permission.storage,
      if (await Permission.photos.isPermanentlyDenied == false)
        Permission.mediaLibrary,
    ].request();

    bool allGranted = await Permission.camera.isGranted &&
        (await Permission.photos.isGranted ||
            await Permission.mediaLibrary.isGranted);

    setState(() {
      _permissionsGranted = allGranted;
    });

    if (!allGranted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera and storage permissions are required for uploading images'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Uri buildWebViewUri(String baseUrl, Map<String, String> params) {
    final uri = Uri.parse(baseUrl);
    final newParams = Map<String, String>.from(uri.queryParameters)..addAll(params);
    return uri.replace(queryParameters: newParams);
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

                // ---------------------------------------------------------
                // CRITICAL FIX: Stops Android from replacing Razorpay with
                // the "net::ERR_UNKNOWN_URL_SCHEME" error screen natively.
                // ---------------------------------------------------------
                disableDefaultErrorPage: true,
              ),
              onLoadStart: (controller, url) async {
                setState(() {
                  _isLoading = true;
                });
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final uriRequest = navigationAction.request.url;
                if (uriRequest == null) return NavigationActionPolicy.ALLOW;

                final urlString = uriRequest.toString();
                final scheme = uriRequest.scheme.toLowerCase();

                // 1. Intercept all UPI and Intent schemes
                if (['upi', 'gpay', 'phonepe', 'paytmmp', 'intent'].contains(scheme)) {

                  // FIRE AND FORGET: Notice there is NO 'await' here.
                  // This allows Flutter to immediately return CANCEL.
                  launchUrl(
                      uriRequest,
                      mode: LaunchMode.externalApplication
                  ).then((launched) {
                    if (!launched && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Payment app not found on this device."),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }).catchError((e) {
                    debugPrint("Error launching deep link: $e");
                  });

                  return NavigationActionPolicy.CANCEL;
                }

                // 2. Handle your existing downloads
                if (DownloadService.isDownloadableUrl(urlString)) {
                  await DownloadService.downloadFile(
                    url: urlString,
                    context: context,
                  );
                  return NavigationActionPolicy.CANCEL;
                }

                return NavigationActionPolicy.ALLOW;
              },
              onReceivedError: (controller, request, error) async {
                // THE FIX: If Chromium bypassed our Cancel request and showed the error,
                // we instantly force the WebView to go back to the Razorpay UI.
                if (error.description == "net::ERR_UNKNOWN_URL_SCHEME" || error.type == -10) {
                  debugPrint("Caught ERR_UNKNOWN_URL_SCHEME. Forcing UI back to Razorpay.");
                  if (await controller.canGoBack()) {
                    await controller.goBack();
                  }
                  setState(() {
                    _isLoading = false;
                  });
                  return;
                }

                // Handle standard errors
                setState(() {
                  _isLoading = false;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  _isLoading = false;
                });

                // Keep your existing JS file input logic intact
                final acceptValue = Platform.isIOS ? 'image/jpeg,image/png' : 'image/*';
                final shouldSetCapture = Platform.isAndroid;
                await controller.evaluateJavascript(source: """
                  (function() {
                    var fileInputs = document.querySelectorAll('input[type="file"]');
                    fileInputs.forEach(function(input) {
                      if (!input.hasAttribute('accept')) input.setAttribute('accept', '$acceptValue');
                      if ($shouldSetCapture) {
                        if (!input.hasAttribute('capture')) input.setAttribute('capture', 'environment');
                      } else if (input.hasAttribute('capture')) {
                        input.removeAttribute('capture');
                      }
                    });
                  })();
                """);
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
            if (_isLoading) const Center(child: CircularProgressIndicator()), // Or your getLoaderWidget()
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