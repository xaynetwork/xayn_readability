import 'package:html/dom.dart' as dom;
import 'package:reader_mode/src/process_html/extensions/node_extensions.dart';
import 'package:reader_mode/src/process_html/objects/flag.dart';

/// An extension on [dom.Node] to facilitate parsing
extension NodeInitializeExtension on dom.Node {
  /// Initializes readability content scores.
  /// Different tag names can yield different initial values.
  void initialize(Flag flag) {
    final node = this;
    var readability = const Readability();

    if (node is dom.Element) {
      switch (node.localName?.toUpperCase()) {
        case 'DIV':
          readability =
              readability.withContentScore(readability.contentScore + 5);
          break;

        case 'PRE':
        case 'TD':
        case 'BLOCKQUOTE':
          readability =
              readability.withContentScore(readability.contentScore + 3);
          break;

        case 'ADDRESS':
        case 'OL':
        case 'UL':
        case 'DL':
        case 'DD':
        case 'DT':
        case 'LI':
        case 'FORM':
          readability =
              readability.withContentScore(readability.contentScore - 3);
          break;

        case 'H1':
        case 'H2':
        case 'H3':
        case 'H4':
        case 'H5':
        case 'H6':
        case 'TH':
          readability =
              readability.withContentScore(readability.contentScore - 5);
          break;
      }
    }

    setReadabilityContentScore(readability.contentScore + getClassWeight(flag));
  }
}
