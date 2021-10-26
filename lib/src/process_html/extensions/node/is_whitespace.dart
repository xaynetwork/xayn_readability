import 'package:html/dom.dart' as dom;

/// An extension on [dom.Node] to facilitate parsing
extension NodeIsWhitespaceExtension on dom.Node {
  /// Checks if this [dom.Node] is only whitespace, or not.
  bool get isWhitespace =>
      (nodeType == dom.Node.TEXT_NODE && (text ?? '').trim().isEmpty) ||
      (nodeType == dom.Node.ELEMENT_NODE &&
          (this as dom.Element).localName?.toLowerCase() == 'br');
}
