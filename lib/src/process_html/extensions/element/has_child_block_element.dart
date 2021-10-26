import 'package:html/dom.dart' as dom;

const _divToPElements = {
  'BLOCKQUOTE',
  'DL',
  'DIV',
  'IMG',
  'OL',
  'P',
  'PRE',
  'TABLE',
  'UL'
};

/// An extension on [dom.Element] to facilitate parsing
extension ElementHasChildBlockElementExtension on dom.Element {
  /// Tests if this element's children contain any nodes which are present in [_divToPElements].
  bool get hasChildBlockElement => children.any((node) =>
      _divToPElements.contains(node.localName?.toUpperCase()) ||
      node.hasChildBlockElement);
}
