import 'package:collection/collection.dart';
import 'package:html/dom.dart' as dom;

/// An extension on [dom.Node] to facilitate parsing
extension NodeIsProbablyVisibleExtension on dom.Node {
  /// An optimistic-check which tries to determine if this [dom.Node] is actually visible
  /// when rendered in plain HTML.
  bool get isProbablyVisible {
    final style = attributes['style'];

    findStyleValue(String style, String name) {
      final split = style.split(';');
      final match = split.firstWhereOrNull(
          (it) => it.split(':').first.trim().toLowerCase() == name);

      return match?.split(':').last.trim();
    }

    // Have to null-check node.style and node.className.indexOf to deal with SVG and MathML nodes.
    return (style == null || findStyleValue(style, 'display') != 'none') &&
        !attributes.containsKey('hidden')
        //check for "fallback-image" so that wikimedia math images are displayed
        &&
        (!attributes.containsKey('aria-hidden') ||
            attributes['aria-hidden'] != 'true' ||
            (this is dom.Element &&
                (this as dom.Element).className.isNotEmpty &&
                (this as dom.Element).className.contains('fallback-image')));
  }
}
