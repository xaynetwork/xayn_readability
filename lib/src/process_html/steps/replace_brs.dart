import 'package:html/dom.dart' as dom;

import 'package:xayn_readability/src/process_html/extensions/extensions.dart';

/// Replaces BR tags
void replaceBrs(final dom.Document document) {
  const brTagName = 'br';
  const pTagName = 'p';
  const divTagName = 'div';

  if (document.body == null) {
    return;
  }

  final element = document.body!;
  final brTags = element.querySelectorAll(brTagName);

  for (var it in brTags) {
    var next = it.nextElementSibling;
    var replaced = false;

    while (next != null &&
        next == next.nextNode &&
        next.matchesExactTagName(brTagName)) {
      final brSibling = next.nextElementSibling;

      replaced = true;
      next.remove();
      next = brSibling;
    }

    if (replaced) {
      final paragraph = document.createElement(pTagName);

      it.replaceWith(paragraph);

      var next = paragraph.nextElementSibling;

      while (next != null) {
        // If we've hit another <br><br>, we're done adding children to this <p>.
        if (next.matchesExactTagName(brTagName)) {
          final nextElem = next.nextElementSibling?.nextNode;

          if (nextElem is dom.Element &&
              nextElem.matchesExactTagName(brTagName)) {
            break;
          }
        }

        if (!next.isPhrasingContent) {
          break;
        }

        // Otherwise, make this node a child of the new <p>.
        final sibling = next.nextElementSibling;

        paragraph.append(next);

        next = sibling;
      }

      while (paragraph.children.isNotEmpty &&
          paragraph.children.last.isWhitespace) {
        paragraph.children.last.remove();
      }

      final paragraphParent = paragraph.parent;

      if (paragraphParent != null &&
          paragraphParent.matchesExactTagName(pTagName)) {
        paragraphParent.swappedTagName(document, divTagName);
      }
    }
  }
}

extension _ElementExtension on dom.Element {
  bool matchesExactTagName(final String match) {
    // expect a trimmed and lower cased match.
    // perform check in debug only to save precious cpu cycles.
    assert(match == match.trim().toLowerCase());

    return localName?.toLowerCase() == match;
  }
}
