import 'package:html/dom.dart' as dom;
import 'package:xayn_readability/xayn_readability.dart';

/// Given the provided [payload], creates a [ProcessHtmlResult] which contains
/// a reader-mode representation of a HTML Document.
ProcessHtmlResult makeReadable(final MakeReadablePayload payload) {
  final document = dom.Document.html(payload.contents);
  final themeColorElement = document.querySelector('meta[name="theme-color"]');
  final descriptionElement = document.querySelector('meta[name="description"]');
  final authorElement = document.querySelector('meta[name="og-author"]');
  final result = parse(document, options: payload.options);
  var themeColor = 0xffffffff;
  String? description, author;

  final htmlTags = document.getElementsByTagName('html');
  final lang = htmlTags.isNotEmpty
      ? htmlTags.first.attributes['lang'] ??
          htmlTags.first.attributes['xml:lang']
      : null;

  if (themeColorElement != null) {
    final value = themeColorElement.attributes['content'];

    if (value != null) {
      themeColor =
          int.tryParse('ff${value.substring(1)}', radix: 16) ?? 0xffffffff;
    }
  }

  if (descriptionElement != null) {
    description = descriptionElement.attributes['content'];
  }

  if (authorElement != null) {
    author = authorElement.attributes['content'];
  }

  return ProcessHtmlResult(
    contents: result?.html,
    favicon: result?.favicon,
    lang: lang,
    textSize: result?.textSize,
    themeColor: themeColor,
    description: description,
    title: document.querySelector("title")?.text,
    author: author,
    metadata: result?.metadata,
  );
}

/// The payload which is passed to [makeReadable]
class MakeReadablePayload {
  /// The HTML contents which should be parsed
  final String contents;

  /// The parser [options]
  final ParserOptions options;

  /// The main constructor to make a new [MakeReadablePayload]
  const MakeReadablePayload({
    required this.contents,
    required this.options,
  });
}
