import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatelessWidget {
  final Uri? uri;
  const WebViewPage({Key? key, required this.uri}) : super(key: key);

  @override
  Widget build(BuildContext context) => uri == null
      ? const Center(child: CircularProgressIndicator())
      : WebView(
          initialUrl: uri.toString(),
        );
}
