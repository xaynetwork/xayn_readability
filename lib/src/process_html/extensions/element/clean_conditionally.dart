import 'package:html/dom.dart' as dom;
import 'package:reader_mode/src/process_html/extensions/node_extensions.dart';
import 'package:reader_mode/src/process_html/objects/flag.dart';
import 'package:reader_mode/src/process_html/util/shared_matchers.dart';

import 'char_count.dart';
import 'link_density.dart';
import 'remove_nodes.dart';
import 'text_density.dart';

/// An extension on [dom.Element] to facilitate parsing
extension ElementCleanConditionallyExtension on dom.Element {
  /// Runs over various different element types and for each individual one,
  /// decides to either keep or remove them.
  void cleanConditionally(String tag, List<dom.Element> tags, Flag flag) {
    if (!flag.isActive(Flag.cleanConditionally)) {
      return;
    }

    // Gather counts for other typical elements embedded within.
    // Traverse backwards so we can remove nodes at the same time
    // without effecting the traversal.
    //
    // TODO: Consider taking into account original contentScore here.
    removeNodes(tags, (node, _, __) {
      // First check if this node IS data table, in which case don't remove it.
      isDataTable(dom.Node? t) => resolveDataTableValue(t) ?? false;

      var isList = const ['ul', 'ol'].contains(tag.toLowerCase());

      if (!isList) {
        var listLength = 0;
        final listNodes = node.querySelectorAll('ul, ol');

        for (var list in listNodes) {
          listLength += list.getInnerText(true).length;
        }

        isList = listLength / node.getInnerText(true).length > 0.9;
      }

      if (tag == 'table' && isDataTable(node)) {
        return false;
      }

      // Next check if we're inside a data table, in which case don't remove it as well.
      if (node.hasAncestorTag(tagName: 'table', maxDepth: -1, f: isDataTable)) {
        return false;
      }

      if (node.hasAncestorTag(tagName: 'code')) {
        return false;
      }

      var weight = node.getClassWeight(flag);

      var contentScore = 0;

      if (weight + contentScore < 0) {
        return true;
      }

      if (node.charCount() < 10) {
        // If there are not very many commas, and the number of
        // non-paragraph elements is more than paragraphs or other
        // ominous signs, remove the element.
        final elements =
            node.querySelectorAll('p, img, li, input, object, embed, iframe');
        var p = 0, img = 0, li = -100, input = 0;

        for (var element in elements) {
          final localName = element.localName?.toLowerCase();

          if (localName == 'p') {
            p++;
          } else if (localName == 'img') {
            img++;
          } else if (localName == 'li') {
            li++;
          } else if (localName == 'input') {
            input++;
          }
        }

        final headingDensity =
            node.getTextDensity(const ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']);

        var embedCount = 0;

        final embeds = elements
            .where((it) => const ['object', 'embed', 'iframe']
                .contains(it.localName?.toLowerCase()))
            .toList(growable: false);

        for (var i = 0, len = embeds.length; i < len; i++) {
          // If this embed has attribute that matches video regex, don't delete it.
          for (var j = 0, len2 = embeds[i].attributes.length; j < len2; j++) {
            final value = embeds[i].attributes[j];

            if (value != null && videoMatcher.hasMatch(value)) {
              return false;
            }
          }

          // For embed with <object> tag, check inner HTML as well.
          if (embeds[i].localName?.toLowerCase() == 'object' &&
              videoMatcher.hasMatch(embeds[i].innerHtml)) {
            return false;
          }

          embedCount++;
        }

        var linkDensity = node.linkDensity;
        var contentLength = node.getInnerText(true).length;

        var haveToRemove = (img > 1 &&
                p / img < 0.5 &&
                !node.hasAncestorTag(tagName: 'figure')) ||
            (!isList && li > p) ||
            (input > (p / 3).floor()) ||
            (!isList &&
                headingDensity < 0.9 &&
                contentLength < 25 &&
                (img == 0 || img > 2) &&
                !node.hasAncestorTag(tagName: 'figure')) ||
            (!isList && weight < 25 && linkDensity > 0.2) ||
            (weight >= 25 && linkDensity > 0.5) ||
            ((embedCount == 1 && contentLength < 75) || embedCount > 1);
        return haveToRemove;
      }
      return false;
    });
  }
}
