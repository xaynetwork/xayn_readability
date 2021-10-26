import 'package:html/dom.dart' as dom;

/// An extension on [dom.Node] to facilitate parsing
extension NodeNextElementNodeExtension on dom.Node {
  /// Returns the next first [dom.Element] relative to this [dom.Node].
  dom.Element? get nextElementNode {
    var list = parent?.nodes ?? const <dom.Node>[];
    final startIndex = list.indexOf(this);

    list = list
        .sublist(startIndex)
        .where((it) => it.nodeType == dom.Node.ELEMENT_NODE)
        .toList(growable: false);

    if (list.isNotEmpty) {
      return list.first as dom.Element;
    }

    return null;
  }
}
