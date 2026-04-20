import 'package:flutter/material.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/services/download_service.dart';

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
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
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
                // Handle download requests
                await DownloadService.downloadFile(
                  url: url.url.toString(),
                  context: context,
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
