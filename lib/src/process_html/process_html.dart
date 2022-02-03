import 'dart:developer';

import 'package:html/dom.dart' as dom;
import 'package:xayn_readability/src/process_html/objects/parser_options.dart';
import 'package:xayn_readability/src/process_html/steps/grab_favicon.dart';
import 'package:xayn_readability/src/process_html/steps/steps.dart';

/// Takes a [document] and parses it to become a new reader mode article.
/// Use [options] to modify the way the parser runs.
_ProcessedHtml? parse(
  final dom.Document document, {
  final ParserOptions options = const ParserOptions(),
}) {
  try {
    var metadata =
        options.disableJsonLd ? const Metadata() : getJsonLd(document);

    // grab favicon link
    final favicon = grabFavicon(document, options);

    // Unwrap image from noscript
    unwrapNoscriptImages(document);

    // Remove script tags from the document.
    removeScripts(document);
    prepDocument(document);

    final result = grabArticle(document, options: options);
    final element = result.element;
    final byLine = result.byLine;

    if (element == null) {
      return null;
    } else {
      postProcess(document, element, options);
    }

    if (byLine != null && metadata.byline == null) {
      metadata = metadata.withByline(byLine);
    }

    return _ProcessedHtml(
      html: element.innerHtml,
      favicon: favicon,
      textSize: element.text.length,
      metadata: metadata,
    );
  } catch (e, s) {
    log('$e $s');
  }
}

class _ProcessedHtml {
  final String html;
  final String favicon;
  final int textSize;
  final Metadata metadata;

  const _ProcessedHtml({
    required this.html,
    required this.favicon,
    required this.textSize,
    required this.metadata,
  });
}
