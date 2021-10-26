import 'package:html/dom.dart' as dom;

final RegExp _b64DataUrlMatcher =
    RegExp(r'^data:\s*([^\s;,]+)\s*;\s*base64\s*,', caseSensitive: false);

/// An extension on [dom.Element] to facilitate parsing
extension ElementFixLazyImagesExtension on dom.Element {
  /// Gets rid of any lazy images and also rewrites the image's src attribute if needed.
  void fixLazyImages(final dom.Document document) {
    final nodes = const ['img', 'picture', 'figure']
        .map(getElementsByTagName)
        .expand((it) => it)
        .toList();

    for (var elem in nodes) {
      // In some sites (e.g. Kotaku), they put 1px square image as base64 data uri in the src attribute.
      // So, here we check if the data uri is too short, just might as well remove it.
      if (elem.attributes.containsKey('src') &&
          _b64DataUrlMatcher.hasMatch(elem.attributes['src']!)) {
        final src = elem.attributes['src']!;
        // Make sure it's not SVG, because SVG can have a meaningful image in under 133 bytes.
        var parts = _b64DataUrlMatcher.firstMatch(elem.attributes['src']!);

        if (parts != null && parts.group(1) == 'image/svg+xml') {
          return;
        }

        // Make sure this element has other attributes which contains image.
        // If it doesn't, then this src is important and shouldn't be removed.
        var srcCouldBeRemoved = false;

        for (var i = 0, len = elem.attributes.length; i < len; i++) {
          final attr = elem.attributes[i];

          if (attr == 'src') {
            continue;
          }

          if (attr != null &&
              RegExp(r'\.(jpg|jpeg|png|webp)', caseSensitive: false)
                  .hasMatch(attr)) {
            srcCouldBeRemoved = true;
            break;
          }
        }

        // Here we assume if image is less than 100 bytes (or 133B after encoded to base64)
        // it will be too small, therefore it might be placeholder image.
        if (srcCouldBeRemoved) {
          var b64starts = RegExp(r'base64\s*', caseSensitive: false)
                  .firstMatch(src)!
                  .start +
              7;
          var b64length = src.length - b64starts;

          if (b64length < 133) {
            elem.attributes.remove('src');
          }
        }
      }

      // also check for "null" to work around https://github.com/jsdom/jsdom/issues/2580
      if ((elem.attributes.containsKey('srcset')) &&
          elem.className.toLowerCase().contains('lazy')) {
        return;
      }

      for (var j = 0, len = elem.attributes.keys.length; j < len; j++) {
        final attr = elem.attributes.keys.elementAt(j);

        if (const ['src', 'srcset', 'alt'].contains(attr)) {
          continue;
        }

        String? copyTo;

        if (RegExp(r'\.(jpg|jpeg|png|webp)\s+\d', caseSensitive: true)
            .hasMatch(elem.attributes[attr] ?? '')) {
          copyTo = 'srcset';
        } else if (RegExp(r'^\s*\S+\.(jpg|jpeg|png|webp)\S*\s*$',
                caseSensitive: true)
            .hasMatch(elem.attributes[attr] ?? '')) {
          copyTo = 'src';
        }

        if (copyTo != null) {
          //if this is an img or picture, set the attribute directly
          if (const ['img', 'picture']
              .contains(elem.localName?.toLowerCase())) {
            elem.attributes[copyTo] = elem.attributes[attr]!;
          } else if (elem.localName?.toLowerCase() == 'figure' &&
              const ['img', 'picture']
                  .map(elem.getElementsByTagName)
                  .expand((it) => it)
                  .isNotEmpty) {
            //if the item is a <figure> that does not contain an image or picture, create one and place it inside the figure
            //see the nytimes-3 testcase for an example
            final img = document.createElement('img');

            img.attributes[copyTo] = elem.attributes[attr] ?? '';

            elem.append(img);
          }
        }
      }
    }
  }
}
