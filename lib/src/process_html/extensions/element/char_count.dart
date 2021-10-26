import 'package:html/dom.dart' as dom;
import 'package:reader_mode/src/process_html/extensions/node_extensions.dart';

/// An extension on [dom.Element] to facilitate parsing
extension ElementCharCountExtension on dom.Element {
  /// Uses [splitter] to divide the inner text into parts and then returns
  /// the amount of parts that were discovered.
  int charCount([String splitter = ',']) =>
      getInnerText(true).split(splitter).length - 1;
}
