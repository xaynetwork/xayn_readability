import 'package:html/dom.dart' as dom;

import 'package:reader_mode/src/process_html/extensions/extensions.dart';

/// Runs a simplification algorithm on the tree from [element]
void simplifyNestedElements(final dom.Element element) {
  dom.Element? node = element;

  while (node != null) {
    if (node.parentNode != null &&
        const ['div', 'section'].contains(node.localName?.toLowerCase()) &&
        !(node.id.startsWith('readability'))) {
      if (node.isWithoutContent) {
        final next = node.getNextNode(true);
        node.remove();
        node = next;
        continue;
      } else if (node.hasSingleTag('div') || node.hasSingleTag('section')) {
        final child = node.children.first;

        for (var i = 0, len = node.attributes.keys.length; i < len; i++) {
          final key = node.attributes.keys.elementAt(i);

          child.attributes[key] = node.attributes[key]!;
        }

        node.replaceWith(child);
        node = child;

        continue;
      }
    }

    node = node.getNextNode(false);
  }
}
