import 'package:html/dom.dart' as dom;

final RegExp _hasContentMatcher = RegExp(r'\S$');

/// An extension on [dom.Element] to facilitate parsing
extension ElementHasSingleTagExtension on dom.Element {
  /// Returns true, if this [dom.Element] contains exactly one child that _does not_ match
  /// the tag name of this element.
  bool hasSingleTag(final String tag) {
    assert(tag == tag.trim().toLowerCase());

    // There should be exactly 1 element child with given tag
    if (children.length != 1 ||
        children.first.localName?.toLowerCase() != tag) {
      return false;
    }

    // And there should be no text nodes with real content
    return !nodes.any((it) =>
        it.nodeType == dom.Node.TEXT_NODE &&
        it.text != null &&
        _hasContentMatcher.hasMatch(it.text!));
  }
}
