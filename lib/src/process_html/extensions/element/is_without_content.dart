import 'package:html/dom.dart' as dom;

/// An extension on [dom.Element] to facilitate parsing
extension ElementIsWithoutContentExtension on dom.Element {
  /// Tests this [dom.Element] and returns true only if it contains any representable text.
  bool get isWithoutContent =>
      text.trim().isEmpty &&
      (children.isEmpty ||
          children.length == querySelectorAll('br, hr').length);
}
