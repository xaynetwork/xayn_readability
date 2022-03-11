import 'package:html/dom.dart' as dom;
import 'package:xayn_readability/src/process_html/objects/parser_options.dart';

/// Find the fav icon
String grabFavicon(final dom.Document document, final ParserOptions options) {
  const rel = [
    'icon',
    'shortcut icon',
    'apple-touch-icon',
    'apple-touch-icon-precomposed',
  ];
  final selectors = rel.map((it) => 'link[rel="$it"]');
  final favIconNodes = document.querySelectorAll(selectors.join(', '));
  var url = '/favicon.ico';

  if (favIconNodes.isNotEmpty) {
    final link = favIconNodes.lastWhere(
        (it) => it.attributes.containsKey('href'),
        orElse: () => favIconNodes.last);

    url = link.attributes['href'] ?? '/favicon.ico';
  }

  return options.baseUri?.resolveUri(Uri.parse(url)).toString() ?? url;
}
