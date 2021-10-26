import 'package:html/dom.dart' as dom;

/// An extension on [dom.Element] to facilitate parsing
extension ElementGetNextNodeExtension on dom.Element {
  /// Returns the next node, if [ignoreSelfAndKids] is true, then
  /// the nearest next neighbour is returned, otherwise if false, then
  /// this element's child nodes are also considered as valid candidates.
  dom.Element? getNextNode(bool ignoreSelfAndKids) {
    // First check for kids if those aren't being ignored
    if (!ignoreSelfAndKids && children.isNotEmpty) {
      return children.first;
    }

    final maybeSibling = nextElementSibling;

    // Then for siblings...
    if (maybeSibling != null) {
      return maybeSibling;
    }

    // And finally, move up the parent chain *and* find a sibling
    // (because this is depth-first traversal, we will have already
    // seen the parent nodes themselves).
    dom.Element? node = this;

    do {
      node = node?.parent;
    } while (node != null && node.nextElementSibling == null);

    return node?.nextElementSibling;
  }
}
