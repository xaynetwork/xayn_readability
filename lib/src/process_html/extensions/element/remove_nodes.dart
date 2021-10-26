import 'package:html/dom.dart' as dom;

/// The signature of [ElementRemoveNodesExtension.removeNodes]' predicate functions.
typedef ShouldRemoveNode = bool Function(
    dom.Element node, int index, List<dom.Element> nodeList);

/// An extension on [dom.Element] to facilitate parsing
extension ElementRemoveNodesExtension on dom.Element {
  /// A utility which removes any [dom.Element]'s from [nodeList],
  /// where the individual [dom.Element] matches the predicate as defined by [f].
  void removeNodes(List<dom.Element> nodeList, ShouldRemoveNode? f) {
    for (var i = nodeList.length - 1; i >= 0; i--) {
      final node = nodeList[i];
      final parentNode = node.parentNode;

      if (parentNode != null) {
        if (f == null || f(node, i, nodeList)) {
          node.remove();
        }
      }
    }
  }
}
