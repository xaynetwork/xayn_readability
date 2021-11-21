import 'package:html/dom.dart' as dom;
import 'package:xayn_readability/src/process_html/extensions/extensions.dart';
import 'package:xayn_readability/src/process_html/objects/parser_options.dart';
import 'package:xayn_readability/src/process_html/steps/fix_relative_uris.dart';
import 'package:xayn_readability/src/process_html/steps/simplify_nested_elements.dart';

/// A collection of actions which run as a post-process
void postProcess(final dom.Document document, final dom.Element element,
    final ParserOptions options) {
  final baseUri = options.baseUri;

  // Readability cannot open relative uris so we convert them to absolute uris.
  fixRelativeUris(document, element);

  simplifyNestedElements(element);

  element.cleanClasses(options);

  if (baseUri != null && baseUri.hasScheme) {
    try {
      element.rewriteSources(document, baseUri);
    } catch (e) {
      // ignore
    }
  }

  // extra cleaning
  document
      .getElementsByTagName('li')
      .where((it) => it.text.trim().isEmpty)
      .forEach((it) => it.remove());
}
