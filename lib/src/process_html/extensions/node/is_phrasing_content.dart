import 'package:html/dom.dart' as dom;

/// An extension on [dom.Node] to facilitate parsing
extension NodeIsPhrasingContentExtension on dom.Node {
  /// Determines if this [dom.Node] qualifies as a phrasing element.
  bool get isPhrasingContent {
    const phrasingElements = [
      // "CANVAS", "IFRAME", "SVG", "VIDEO",
      'ABBR', 'AUDIO', 'B', 'BDO', 'BR', 'BUTTON', 'CITE', 'CODE', 'DATA',
      'DATALIST', 'DFN', 'EM', 'EMBED', 'I', 'IMG', 'INPUT', 'KBD', 'LABEL',
      'MARK', 'MATH', 'METER', 'NOSCRIPT', 'OBJECT', 'OUTPUT', 'PROGRESS', 'Q',
      'RUBY', 'SAMP', 'SCRIPT', 'SELECT', 'SMALL', 'SPAN', 'STRONG', 'SUB',
      'SUP', 'TEXTAREA', 'TIME', 'VAR', 'WBR'
    ];
    const secondaryElements = ['A', 'DEL', 'INS'];

    if (nodeType == dom.Node.TEXT_NODE) {
      return true;
    }

    final node = this;

    if (node is dom.Element) {
      final name = node.localName?.toUpperCase();

      return phrasingElements.contains(name) ||
          (secondaryElements.contains(name) &&
              nodes.every((it) => it.isPhrasingContent));
    }

    return false;
  }
}
