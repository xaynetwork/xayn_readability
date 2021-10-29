import 'package:html/dom.dart' as dom;
import 'package:xayn_readability/src/process_html/extensions/node_extensions.dart';

/// An extension on [dom.Element] to facilitate parsing
extension ElementTextDensityExtension on dom.Element {
  /// Calculates the text density of the current [dom.Element].
  double getTextDensity(List<String> tags) {
    var textLength = getInnerText(true).length;

    if (textLength == 0) {
      return 0;
    }

    var childrenLength = .0;
    final children = querySelectorAll(tags.join(', '));

    for (var child in children) {
      childrenLength += child.getInnerText(true).length;
    }

    return childrenLength / textLength;
  }
}
