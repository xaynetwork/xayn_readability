import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:reader_mode/reader_mode.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController textEditingController = TextEditingController();
  final ReaderModeController readerModeController = ReaderModeController();

  @override
  void initState() {
    readerModeController.addListener(() {
      setState(() {
        textEditingController.text = readerModeController.uri.toString();
      });
    });

    //readerModeController.loadUri(Uri.parse('https://de.m.wikipedia.org/wiki/Berlin'));
    readerModeController.loadUri(Uri.parse(
        'https://www.ign.com/articles/metroid-dread-review-nintendo-switch'));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          child: Container(
            color: Colors.red,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                children: [
                  AbsorbPointer(
                    absorbing: !readerModeController.canGoBack,
                    child: Opacity(
                      opacity: readerModeController.canGoBack ? 1.0 : .333,
                      child: ElevatedButton(
                        onPressed: readerModeController.back,
                        child: const Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: TextField(
                        onSubmitted: (value) {
                          readerModeController.loadUri(Uri.parse(value));
                        },
                        controller: textEditingController,
                      ),
                    ),
                  ),
                  AbsorbPointer(
                    absorbing: !readerModeController.canGoForward,
                    child: Opacity(
                      opacity: readerModeController.canGoForward ? 1.0 : .333,
                      child: ElevatedButton(
                        onPressed: readerModeController.forward,
                        child: const Icon(Icons.arrow_forward),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          preferredSize: const Size(double.infinity, 60.0)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ReaderMode(
            userAgent:
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36',
            classesToPreserve: const [
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
            ],
            onImageTap: (metadata) {
              log(metadata?.sources.join(', ') ?? metadata?.title ?? 'image');
            },
            controller: readerModeController,
          );
        },
      ),
    );
  }
}
