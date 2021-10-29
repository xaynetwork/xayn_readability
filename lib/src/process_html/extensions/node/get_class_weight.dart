import 'package:html/dom.dart' as dom;
import 'package:xayn_readability/src/process_html/objects/flag.dart';

final RegExp _positiveMatcher = RegExp(
    r'article|body|content|entry|hentry|h-entry|main|page|pagination|post|text|blog|story',
    caseSensitive: false);
final RegExp _negativeMatcher = RegExp(
    r'-ad-|hidden|^hid$| hid$| hid |^hid |banner|combx|comment|com-|contact|foot|footer|footnote|gdpr|masthead|media|meta|outbrain|promo|related|scroll|share|shoutbox|sidebar|skyscraper|sponsor|shopping|tags|tool|widget',
    caseSensitive: false);

/// An extension on [dom.Node] to facilitate parsing
extension NodeGetClassWeightExtension on dom.Node {
  /// Attempts to calculate the importance of class names on this [dom.Element].
  /// The lowest score is 0, which is also the scrore that is returned, should [Flag.weightClasses] be disabled.
  int getClassWeight(final Flag flag) {
    if (!flag.isActive(Flag.weightClasses)) {
      return 0;
    }

    final node = this;
    var weight = 0;

    // Look for a special classname
    if (node is dom.Element && node.className.isNotEmpty) {
      if (_negativeMatcher.hasMatch(node.className)) {
        weight -= 25;
      }

      if (_positiveMatcher.hasMatch(node.className)) {
        weight += 25;
      }
    }

    // Look for a special ID
    if (node is dom.Element && node.id.isNotEmpty) {
      if (_negativeMatcher.hasMatch(node.id)) {
        weight -= 25;
      }

      if (_positiveMatcher.hasMatch(node.id)) {
        weight += 25;
      }
    }

    return weight;
  }
}
