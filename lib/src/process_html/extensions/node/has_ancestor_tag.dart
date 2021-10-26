import 'package:html/dom.dart' as dom;

/// The signature of [NodeHasAncestorTagExtension.hasAncestorTag] functions.
typedef HasAncestorTagFilter = bool Function(dom.Node?);

/// An extension on [dom.Node] to facilitate parsing
extension NodeHasAncestorTagExtension on dom.Node {
  /// Checks if this [dom.Node] has an ancestor, returns true if it does have one.
  bool hasAncestorTag(
      {required String tagName, int maxDepth = 3, HasAncestorTagFilter? f}) {
    final tagNameUc = tagName.toUpperCase();
    var depth = 0;
    dom.Node? node = this;

    while (node?.parent != null) {
      if (maxDepth > 0 && depth > maxDepth) {
        return false;
      }
      if (node?.parent?.localName?.toUpperCase() == tagNameUc &&
          (f == null || f(node?.parentNode))) {
        return true;
      }

      node = node?.parentNode;

      depth++;
    }

    return false;
  }
}
