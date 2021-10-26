import 'package:html/dom.dart' as dom;

import 'package:reader_mode/src/process_html/extensions/extensions.dart';

final RegExp _imageExtensionsMatcher =
    RegExp(r'\.(jpg|jpeg|png|webp)', caseSensitive: false);

/// Find img without source or attributes that might contains image, and remove it.
/// This is done to prevent a placeholder img is replaced by img from noscript in next step.
void unwrapNoscriptImages(final dom.Document document) {
  final images = document.getElementsByTagName('img');
  const sourceAttributes = ['src', 'srcset', 'data-src', 'data-srcset'];

  images.where((image) {
    final attributes = image.attributes.keys.map((it) {
      if (it is dom.AttributeName) {
        return it.name;
      }

      return it as String;
    }).toSet();

    final hasNoMatchingValue =
        image.attributes.values.any(_imageExtensionsMatcher.hasMatch);
    final hasNoMatchingSource =
        sourceAttributes.any((it) => !attributes.add(it.toLowerCase()));

    return !hasNoMatchingValue && !hasNoMatchingSource;
  }).forEach((it) => it.remove());

  // Next find noscript and try to extract its image
  final noScripts = document.getElementsByTagName('noscript').toList();

  for (var it in noScripts) {
    final tmp = document.createElement('div')..innerHtml = it.innerHtml;

    if (!tmp.isSingleImage) {
      return;
    }

    final prevElement = it.previousElementSibling;

    if (prevElement != null && prevElement.isSingleImage) {
      var prevImage = prevElement;

      if (prevImage.localName?.toLowerCase() != 'img') {
        prevImage = prevElement.getElementsByTagName('img').first;
      }

      final newImage = tmp.getElementsByTagName('img').first;

      for (var i = 0, len = prevImage.attributes.keys.length; i < len; i++) {
        final key = prevImage.attributes.keys.elementAt(i);
        final keyAsString =
            (key is dom.AttributeName ? key.name : key as String).toLowerCase();
        final value = prevImage.attributes[key]!;

        if (value.isEmpty) {
          continue;
        }

        if (const ['src', 'srcset'].contains(keyAsString) ||
            _imageExtensionsMatcher.hasMatch(value)) {
          if (newImage.attributes[key] == value) {
            continue;
          }

          final attributeName = newImage.attributes.containsKey(key)
              ? 'data-old-$keyAsString'
              : keyAsString;

          newImage.attributes[attributeName] = value;
        }
      }

      tmp.children.first.replaceWith(prevElement);
    }
  }
}
