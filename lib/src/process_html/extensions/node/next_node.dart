import 'package:html/dom.dart' as dom;

/// An extension on [dom.Node] to facilitate parsing
extension NodeNextNodeExtension on dom.Node {
  /// Returns the next first [dom.Node] relative to this [dom.Node].
  dom.Node? get nextNode {
    final list = parent?.nodes ?? const <dom.Node>[];
    final len = list.length;
    final startIndex = list.indexOf(this);

    if (startIndex >= 0 && startIndex < len - 1) {
      return list[startIndex + 1];
    }

    return null;
  }
}
