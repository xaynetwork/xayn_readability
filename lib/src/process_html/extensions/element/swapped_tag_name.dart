import 'package:html/dom.dart' as dom;
import 'package:reader_mode/src/process_html/extensions/node_extensions.dart';

/// An extension on [dom.Element] to facilitate parsing
extension ElementSwappedTagNameExtension on dom.Element {
  /// Swaps the tag name for this [dom.Element] for the one provided with [tagName].
  dom.Element swappedTagName(
      final dom.Document document, final String tagName) {
    var replacement = document.createElement(tagName);

    while (firstChild != null) {
      replacement.append(firstChild!);
    }

    replaceWith(replacement);

    if (hasReadability) {
      replacement.setReadabilityContentScore(readabilityContentScore);
    }

    for (var i = 0, len = attributes.keys.length; i < len; i++) {
      try {
        final key = attributes.keys.elementAt(i);

        replacement.attributes[key] = attributes[key]!;
      } catch (e) {
        /* it's possible for setAttribute() to throw if the attribute name
         * isn't a valid XML Name. Such attributes can however be parsed from
         * source in HTML docs, see https://github.com/whatwg/html/issues/4275,
         * so we can hit them here and then throw. We don't care about such
         * attributes so we ignore them.
         */
      }
    }

    return replacement;
  }
}
