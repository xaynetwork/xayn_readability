import 'package:html/dom.dart' as dom;

/// An extension on [dom.Element] to facilitate parsing
extension ElementGetAncestorsExtension on dom.Element {
  /// Returns a list of ancestors, relative to this [dom.Element]
  List<_AncestorWithLevel> getAncestors([int maxDepth = 0]) {
    var i = 0, ancestors = <_AncestorWithLevel>[];
    dom.Node? node = this;

    while (node?.parent != null) {
      final ancestor = node!.parent!;

      ancestors.add(_AncestorWithLevel(ancestor: ancestor, level: i));

      if (maxDepth > 0 && ++i == maxDepth) {
        break;
      }

      node = node.parent;
    }

    return ancestors;
  }
}

class _AncestorWithLevel {
  final dom.Element ancestor;
  final int level;

  const _AncestorWithLevel({
    required this.ancestor,
    required this.level,
  });
}
