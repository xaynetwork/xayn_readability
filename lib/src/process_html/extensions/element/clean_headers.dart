import 'package:html/dom.dart' as dom;
import 'package:xayn_readability/src/process_html/extensions/node_extensions.dart';
import 'package:xayn_readability/src/process_html/objects/flag.dart';
import 'remove_nodes.dart';

/// An extension on [dom.Element] to facilitate parsing
extension ElementCleanHeadersExtension on dom.Element {
  /// Removes any headers which have insufficient weight
  void cleanHeaders(final Flag flag) => removeNodes(querySelectorAll('h1, h2'),
      (node, _, __) => node.getClassWeight(flag) < 0);
}
