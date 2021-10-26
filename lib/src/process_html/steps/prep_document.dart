import 'package:html/dom.dart' as dom;
import 'package:reader_mode/src/process_html/extensions/extensions.dart';
import 'package:reader_mode/src/process_html/steps/replace_brs.dart';

/// Prepares the [document] to become a reader mode article
void prepDocument(final dom.Document document) {
  final styles = document.querySelectorAll('style'),
      fonts = document.querySelectorAll('font');

  _getCommentNodes(document)
      .toList(growable: false)
      .forEach((it) => it.remove());

  replaceBrs(document);

  for (var it in styles) {
    it.remove();
  }

  for (var it in fonts) {
    it.swappedTagName(document, 'span');
  }
}

Iterable<dom.Node> _getCommentNodes(dom.Node node) sync* {
  if (node.nodeType == dom.Node.COMMENT_NODE) {
    yield node;
  }

  for (var child in node.nodes) {
    yield* _getCommentNodes(child);
  }
}
