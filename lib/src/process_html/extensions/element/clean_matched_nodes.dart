import 'package:html/dom.dart' as dom;

import 'get_next_node.dart';

/// An extension on [dom.Element] to facilitate parsing
extension ElementCleanMatchedNodesExtension on dom.Element {
  /// Removes any nodes which are matched by the predicate [f]
  void cleanMatchedNodes(bool Function(dom.Element, String) f) {
    final endOfSearchMarkerNode = getNextNode(true);
    var next = getNextNode(false);

    while (next != null && next != endOfSearchMarkerNode) {
      if (f(next, '${next.className} ${next.id}')) {
        final n = next.getNextNode(true);

        next.remove();
        next = n;
      } else {
        next = next.getNextNode(false);
      }
    }
  }
}
