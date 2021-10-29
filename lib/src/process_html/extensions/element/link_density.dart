import 'package:html/dom.dart' as dom;
import 'package:xayn_readability/src/process_html/extensions/node_extensions.dart';

final RegExp _hashUrlMatcher = RegExp(r'^#.+', caseSensitive: false);

/// An extension on [dom.Element] to facilitate parsing
extension ElementLinkDensityExtension on dom.Element {
  /// Returns a value which indicates the percentage of how much textual content
  /// is actually wrapped by a link [dom.Element].
  double get linkDensity {
    var textLength = getInnerText(true).length;

    if (textLength == 0) {
      return 0;
    }

    final links = getElementsByTagName('a');
    var linkLength = .0;

    // XXX implement _reduceNodeList?
    for (var it in links) {
      final href = it.attributes['href'];
      final coefficient =
          href != null && _hashUrlMatcher.hasMatch(href) ? .3 : 1.0;

      linkLength += it.getInnerText(true).length * coefficient;
    }

    return linkLength / textLength;
  }
}
