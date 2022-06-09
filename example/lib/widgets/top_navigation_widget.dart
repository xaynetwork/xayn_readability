import 'package:flutter/material.dart';
import 'package:xayn_readability/xayn_readability.dart';

class TopNavigationWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final ReaderModeController readerModeController;

  const TopNavigationWidget({
    Key? key,
    required this.textEditingController,
    required this.readerModeController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backArrowIcon = AbsorbPointer(
      absorbing: !readerModeController.canGoBack,
      child: Opacity(
        opacity: readerModeController.canGoBack ? 1.0 : .333,
        child: IconButton(
          onPressed: readerModeController.back,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
    );

    final forwardArrowIcon = AbsorbPointer(
      absorbing: !readerModeController.canGoForward,
      child: Opacity(
        opacity: readerModeController.canGoForward ? 1.0 : .333,
        child: IconButton(
          onPressed: readerModeController.forward,
          icon: const Icon(Icons.arrow_forward),
        ),
      ),
    );

    final textField = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        onSubmitted: (value) {
          readerModeController.loadUri(Uri.parse(value));
        },
        controller: textEditingController,
      ),
    );

    final row = Row(
      children: [
        Flexible(
          flex: 10,
          child: backArrowIcon,
        ),
        const Spacer(),
        Flexible(
          flex: 10,
          child: forwardArrowIcon,
        ),
        Expanded(
          flex: 70,
          child: textField,
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: row,
    );
  }
}
