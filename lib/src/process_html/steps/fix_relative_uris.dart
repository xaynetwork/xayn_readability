import 'package:html/dom.dart' as dom;

/// Cleans up irrelevant links in reader mode, such as JavaScript links for example.
void fixRelativeUris(final dom.Document document, final dom.Element element) {
  final links = element.getElementsByTagName('a');

  // Remove links with javascript: URIs, since
  // they won't work after scripts have been removed from the page.
  links.where((it) => it.isJsHref).forEach((it) {
    // if the link only contains simple text content, it can be converted to a text node
    if (it.hasSingleTextNode) {
      it.replaceWith(dom.Text(it.text));
    } else {
      // if the link has multiple children, they should all be preserved
      final container = document.createElement('span');

      while (it.nodes.isNotEmpty) {
        container.append(it.nodes.first);
      }

      it.replaceWith(container);
    }
  });
}

extension _ElementExtension on dom.Element {
  bool get isJsHref {
    final href = attributes['href'];

    return href != null && href.contains('javascript:');
  }

  bool get hasSingleTextNode =>
      nodes.length == 1 && nodes.first.nodeType == dom.Node.TEXT_NODE;
}
