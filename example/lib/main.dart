import 'dart:developer';
import 'dart:io';

import 'package:example/data/random_article_web_pages.dart';
import 'package:example/web_view_page.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xayn_readability/xayn_readability.dart';

import 'widgets/bottom_navigation_widget.dart';
import 'widgets/top_navigation_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Read Web Articles',
      theme: ThemeData.dark(),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController textEditingController = TextEditingController();
  final ReaderModeController readerModeController = ReaderModeController();
  bool isReaderModeView = true;

  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = AndroidWebView();

    readerModeController.addListener(() {
      setState(() {
        textEditingController.text = readerModeController.uri.toString();
      });
    });

    loadRandomWebPage();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavigationBar = BottomNavigationWidget(
      isReaderMode: isReaderModeView,
      onTap: toggleReaderMode,
    );

    final floatingActionButton = FloatingActionButton(
      onPressed: loadRandomWebPage,
      child: const Icon(Icons.autorenew),
    );

    final topNavigation = TopNavigationWidget(
      readerModeController: readerModeController,
      textEditingController: textEditingController,
    );

    final body = isReaderModeView
        ? buildReaderMode()
        : WebViewPage(
            key: ValueKey(readerModeController.uri),
            uri: readerModeController.uri);

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          child: topNavigation,
          preferredSize: const Size(double.infinity, 80.0),
        ),
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        body: body,
      ),
    );
  }

  toggleReaderMode(_) => setState(() => isReaderModeView = !isReaderModeView);

  buildReaderMode() {
    const userAgent =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36';

    const classesToPreserve = [
      "caption",
      "emoji",
      "hidden",
      "invisible",
      "sr-only",
      "visually-hidden",
      "visuallyhidden",
      "wp-caption",
      "wp-caption-text",
      "wp-smiley"
    ];

    const loadingWidget = Center(child: CircularProgressIndicator());

    final readerMode = ReaderMode(
      userAgent: userAgent,
      classesToPreserve: classesToPreserve,
      onImageTap: (metadata) {
        log(metadata?.sources.join(', ') ?? metadata?.title ?? 'image');
      },
      controller: readerModeController,
      loadingBuilder: () => loadingWidget,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: readerMode,
    );
  }

  loadRandomWebPage() => readerModeController.loadUri(getRandomArticleUri());
}
