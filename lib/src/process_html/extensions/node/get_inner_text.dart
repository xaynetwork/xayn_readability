import 'package:html/dom.dart' as dom;

final RegExp _normalizeMatcher = RegExp(r'\s{2,}');

/// An extension on [dom.Node] to facilitate parsing
extension NodeGetInnerTextExtension on dom.Node {
  /// Returns the text value in this [dom.Node].
  String getInnerText(bool normalizeSpaces) {
    final content = text?.trim() ?? '';

    if (normalizeSpaces) {
      return content.replaceAll(_normalizeMatcher, ' ');
    }

    return content;
  }
}
