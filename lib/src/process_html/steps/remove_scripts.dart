import 'package:html/dom.dart' as dom;

/// Removes any script tags
void removeScripts(final dom.Document document) {
  final scripts = document.querySelectorAll('script, noscript');

  for (var it in scripts) {
    it.remove();
  }
}
