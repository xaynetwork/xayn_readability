import 'package:html/dom.dart' as dom;
import 'package:xayn_readability/src/process_html/util/shared_matchers.dart';
import 'remove_nodes.dart';

/// An extension on [dom.Element] to facilitate parsing
extension ElementCleanExtension on dom.Element {
  /// Strips out any media types which would not work within the reader mode
  /// context. The tags that are checked are ['object', 'embed', 'iframe'].
  void clean(String tag, List<dom.Element> tags) {
    final isEmbed =
        const ['object', 'embed', 'iframe'].contains(tag.toLowerCase());

    removeNodes(tags, (element, _, __) {
      // Allow youtube and vimeo videos through as people usually want to see those.
      if (isEmbed) {
        // First, check the elements attributes to see if any of them contain youtube or vimeo
        for (var i = 0, len = element.attributes.length; i < len; i++) {
          final value = element.attributes[i];

          if (value != null && videoMatcher.hasMatch(value)) {
            return false;
          }
        }

        // For embed with <object> tag, check inner HTML as well.
        if (element.localName?.toLowerCase() == 'object' &&
            videoMatcher.hasMatch(element.innerHtml)) {
          return false;
        }
      }

      return true;
    });
  }
}
