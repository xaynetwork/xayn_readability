import 'package:html/dom.dart' as dom;

import 'package:reader_mode/src/process_html/extensions/node_extensions.dart';
import 'package:reader_mode/src/process_html/extensions/string_extensions.dart';

/// An extension on [dom.Element] to facilitate parsing
extension ElementHeaderDuplicatesTitleExtension on dom.Element {
  /// Checks if this [dom.Element] is a header, and if it is, then checks
  /// if the textual similarity between it's textual contents and [articleTitle]
  /// are indeed very similar.
  bool headerDuplicatesTitle(String? articleTitle) {
    if (articleTitle == null) {
      return false;
    }

    if (!const ['h1', 'h2'].contains(localName?.toLowerCase())) {
      return false;
    }

    final heading = getInnerText(false);

    return articleTitle.getTextSimilarity(heading) > .75;
  }
}
