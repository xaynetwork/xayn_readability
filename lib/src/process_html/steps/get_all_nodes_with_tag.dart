import 'package:html/dom.dart' as dom;

/// Runs querySelectorAll in the correct context for the [node] provided.
/// Returns a List of [dom.Element]s which match the [tagNames] provided.
List<dom.Element> getAllNodesWithTag({
  required final dom.Node node,
  required final List<String> tagNames,
}) {
  final tagNamesDelimited = tagNames.join(',');
  final selector = node is dom.Element
      ? node.querySelectorAll
      : node is dom.Document
          ? node.querySelectorAll
          : node is dom.DocumentFragment
              ? node.querySelectorAll
              : (String _) => <dom.Element>[];

  return selector(tagNamesDelimited);
}
