import 'package:html/dom.dart' as dom;

/// An extension on [dom.Element] to facilitate parsing
extension ElementGetAncestorsExtension on dom.Element {
  /// Returns a list of ancestors, relative to this [dom.Element]
  List<AncestorWithLevel> getAncestors([int maxDepth = 0]) {
    var i = 0, ancestors = <AncestorWithLevel>[];
    dom.Node? node = this;

    while (node?.parent != null) {
      final ancestor = node!.parent!;

      ancestors.add(AncestorWithLevel(ancestor: ancestor, level: i));

      if (maxDepth > 0 && ++i == maxDepth) {
        break;
      }

      node = node.parent;
    }

    return ancestors;
  }
}

/// Pairs html Elements and the tree level at which they were encountered
class AncestorWithLevel {
  /// References the ancestor Element
  final dom.Element ancestor;

  /// Hold the tree level at which [ancestor] was encountered
  final int level;

  /// Creates a new tuple holding [ancestor] and [level]
  const AncestorWithLevel({
    required this.ancestor,
    required this.level,
  });
}
