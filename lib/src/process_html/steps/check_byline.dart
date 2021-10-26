import 'package:html/dom.dart' as dom;

import 'package:reader_mode/src/process_html/extensions/string_extensions.dart';

/// constant representation of a [CheckBylineResult] which is _not_ a byline.
const notAByLineResult = CheckBylineResult.isNot();

final RegExp _byLineMatcher =
    RegExp(r'byline|author|dateline|writtenby|p-author', caseSensitive: false);

/// Validates a [node] and tries to determine if that given [dom.Node] is a candidate for a byLine.
CheckBylineResult checkByLine(
  final dom.Node node, {
  required final String match,
  final String? articleByline,
}) {
  if (articleByline != null) {
    return notAByLineResult;
  }

  final testAuthorOrMatch =
      node.isAuthor || node.isIndirectAuthor || _byLineMatcher.hasMatch(match);

  if (testAuthorOrMatch) {
    final text = (node.text ?? '').trim();

    if (text.isValidByline) {
      return CheckBylineResult(value: text, isByline: true);
    }
  }

  return notAByLineResult;
}

/// The result of a [dom.Node]'s byLine check.
class CheckBylineResult {
  /// Is true if the node is a valid byLine
  final bool isByline;

  /// Contains the node's textual value
  final String? value;

  /// Creates a new CheckBylineResult
  const CheckBylineResult({required this.isByline, this.value});

  /// Shorthand constructor for a result which is _not_ a byLine
  const CheckBylineResult.isNot()
      : isByline = false,
        value = null;
}

extension _NodeExtension on dom.Node {
  bool get isAuthor => attributes['rel']?.toLowerCase() == 'author';

  bool get isIndirectAuthor {
    final itemprop = attributes['itemprop'];

    if (itemprop != null) {
      return itemprop.toLowerCase().contains('author');
    }

    return false;
  }
}
