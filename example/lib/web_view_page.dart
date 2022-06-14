import 'package:flutter/material.dart';
import 'package:webviewx/webviewx.dart';

class WebViewPage extends StatefulWidget {
  final Uri? uri;

  const WebViewPage({Key? key, required this.uri}) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewXController webviewController;

  @override
  void dispose() {
    webviewController.dispose();
    super.dispose();
  }

  Size get screenSize => MediaQuery.of(context).size;

  @override
  Widget build(BuildContext context) {
    if (widget.uri == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return WebViewX(
      height: screenSize.height,
      width: screenSize.width,
      onWebViewCreated: _onWebViewCreated,
    );
  }

  _loadContent() => webviewController.loadContent(
        widget.uri.toString(),
        SourceType.url,
      );

  _onWebViewCreated(WebViewXController controller) {
    webviewController = controller;
    _loadContent();
  }
}
