import 'package:flutter/material.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/services/download_service.dart';
import 'package:url_launcher/url_launcher.dart';

class FeePaymentScreen extends StatefulWidget {
  final String? title;
  final String url;
  const FeePaymentScreen({super.key, this.title, required this.url});

  @override
  State<FeePaymentScreen> createState() => _FeePaymentScreenState();
}

class _FeePaymentScreenState extends State<FeePaymentScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  Uri buildFeePaymentUri(String baseUrl, Map<String, String> params) {
    final uri = Uri.parse(baseUrl);
    final newParams = Map<String, String>.from(uri.queryParameters)
      ..addAll(params);
    return uri.replace(queryParameters: newParams);
  }

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

    Uri url = buildFeePaymentUri(widget.url, params);

    return AppScaffold(
      body: AppBody(
        title: widget.title ?? 'Fee Payment',
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri.uri(url)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useOnDownloadStart: true,
                useOnLoadResource: true,
                useShouldOverrideUrlLoading: true,
                useHybridComposition: true,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                domStorageEnabled: true,
                databaseEnabled: true,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                if (!_isStandardWebScheme(url?.scheme)) {
                  controller.stopLoading();
                  return;
                }
                setState(() {
                  _isLoading = true;
                });
              },
              onLoadStop: (controller, url) {
                setState(() {
                  _isLoading = false;
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
                controller.stopLoading();

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
              onDownloadStartRequest: (controller, url) async {
                // Handle download requests
                await DownloadService.downloadFile(
                  url: url.url.toString(),
                  context: context,
                );
              },
              onReceivedError: (controller, request, error) async {
                setState(() {
                  _isLoading = false;
                });

                if (error.description == "net::ERR_UNKNOWN_URL_SCHEME") {
                  if (await controller.canGoBack()) {
                    await controller.goBack();
                  }
                }
              },
            ),
            if (_isLoading) Center(child: getLoaderWidget()),
          ],
        ),
      ),
    );
  }
}
