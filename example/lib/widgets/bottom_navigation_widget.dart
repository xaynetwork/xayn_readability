import 'package:flutter/material.dart';

class BottomNavigationWidget extends StatelessWidget {
  final bool isReaderMode;
  final ValueChanged<int>? onTap;

  const BottomNavigationWidget(
      {Key? key, required this.isReaderMode, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const readerModeItem = BottomNavigationBarItem(
      icon: Icon(Icons.text_snippet),
      label: 'Reader mode',
    );

    const webViewItem = BottomNavigationBarItem(
      icon: Icon(Icons.web),
      label: 'Web view',
    );

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        readerModeItem,
        webViewItem,
      ],
      currentIndex: isReaderMode ? 0 : 1,
      onTap: onTap,
    );
  }
}
