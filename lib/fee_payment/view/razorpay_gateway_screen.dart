import 'package:flutter/material.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/services/download_service.dart';
import 'package:url_launcher/url_launcher.dart'; 

class RazorpayGatewayScreen extends StatefulWidget {
  final String? title;
  final String url;
  final double amount; // Keep the amount for consistency
  
  const RazorpayGatewayScreen({
    super.key, 
    this.title, 
    required this.url,
    required this.amount,
  });

  @override
  State<RazorpayGatewayScreen> createState() => _RazorpayGatewayScreenState();
}

class _RazorpayGatewayScreenState extends State<RazorpayGatewayScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;

  Uri buildFeePaymentUri(String baseUrl, Map<String, String> params) {
    final uri = Uri.parse(baseUrl);
    final newParams = Map<String, String>.from(uri.queryParameters)..addAll(params);
    return uri.replace(queryParameters: newParams);
  }

  // Helper to identify standard web protocols
  bool _isWebScheme(String? scheme) {
    if (scheme == null) return false;
    return ['http', 'https', 'about', 'data', 'javascript'].contains(scheme.toLowerCase());
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
      "amount": widget.amount.toString(), // Added amount to params
    };

    Uri url = buildFeePaymentUri(widget.url, params);

    return AppScaffold(
      body: AppBody(
        title: widget.title ?? 'Payment Gateway',
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri.uri(url)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useOnDownloadStart: true,
                useOnLoadResource: true,
                useShouldOverrideUrlLoading: true,
                // CRITICAL: Prevents the white error screen from replacing your Razorpay UI
                disableDefaultErrorPage: true,
                useHybridComposition: true,
                allowsInlineMediaPlayback: true,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                // If the engine tries to load a non-web scheme, kill it instantly
                if (!_isWebScheme(url?.scheme)) {
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

                final urlString = uri.toString();
                final scheme = uri.scheme.toLowerCase();

                // 1. Intercept Payment Schemes (UPI, GPay, PhonePe, Intents)
                if (!['http', 'https', 'about', 'javascript'].contains(scheme)) {
                  try {
                    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                    if (!launched && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("No payment app found for this method."),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('Error launching URL: $e');
                  }
                  return NavigationActionPolicy.CANCEL;
                }

                // 2. Existing Download Logic
                if (DownloadService.isDownloadableUrl(urlString)) {
                  await DownloadService.downloadFile(url: urlString, context: context);
                  return NavigationActionPolicy.CANCEL;
                }

                return NavigationActionPolicy.ALLOW;
              },
              onReceivedError: (controller, request, error) async {
                // If Chromium still shows the error screen, force the UI back to Razorpay
                if (error.description == "net::ERR_UNKNOWN_URL_SCHEME" || error.type == -10) {
                  if (await controller.canGoBack()) {
                    await controller.goBack();
                  }
                  setState(() { _isLoading = false; });
                  return;
                }

                setState(() {
                  _isLoading = false;
                });
              },
              onDownloadStartRequest: (controller, url) async {
                await DownloadService.downloadFile(
                  url: url.url.toString(),
                  context: context,
                );
              },
            ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
