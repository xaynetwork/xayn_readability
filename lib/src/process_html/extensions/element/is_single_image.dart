import 'package:html/dom.dart' as dom;

/// An extension on [dom.Element] to facilitate parsing
extension ElementIsSingleImageExtension on dom.Element {
  /// Recursively scans this [dom.Element] and checks that there is only
  /// 1 nested child, which then also is an ImageElement.
  bool get isSingleImage {
    if (localName?.toLowerCase() == 'img') {
      return true;
    }

    if (children.length != 1 || text.trim().isNotEmpty) {
      return false;
    }

    return children.first.isSingleImage;
  }
}
