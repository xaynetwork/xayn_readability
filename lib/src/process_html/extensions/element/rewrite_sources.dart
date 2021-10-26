import 'package:html/dom.dart' as dom;

/// An extension on [dom.Element] to facilitate parsing
extension RewriteSourcesExtension on dom.Element {
  /// Loops over any tags that contain url references and then rewrites those
  /// to be rebased to [baseUri] if needed.
  /// For example, and src value containing relative links become absolute links, e.g.:
  /// ```html
  /// <img src="/images/image_1.jpg">
  /// ```
  /// rewrites to
  /// ```html
  /// <img src="https://my.base.url/images/image_1.jpg">
  /// ```
  /// Any non-relative sources are left as they were.
  void rewriteSources(final dom.Document document, final Uri baseUri) {
    const props = [
      'src',
      'href',
      'poster',
      'cite',
      'background',
      'usemap',
      'data',
      'codebase',
    ];
    final elements = querySelectorAll(props.map((it) => '[$it]').join(','));

    for (var i = 0, len = elements.length; i < len; i++) {
      final element = elements[i];

      for (var j = 0, len2 = props.length; j < len2; j++) {
        final key = props[j];

        if (element.attributes.containsKey(key)) {
          final value = element.attributes[key]!;
          final valueUri = Uri.parse(value);

          element.attributes[key] = baseUri.resolveUri(valueUri).toString();
        }
      }
    }
  }
}
