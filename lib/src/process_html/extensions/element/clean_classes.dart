import 'package:html/dom.dart' as dom;
import 'package:reader_mode/src/process_html/objects/parser_options.dart';

/// An extension on [dom.Element] to facilitate parsing
extension ElementCleanClassesExtension on dom.Element {
  /// Swipes through all discovered class properties on elements,
  /// and keeps only those that are listen in [ParserOptions.classesToPreserve].
  void cleanClasses(final ParserOptions options) {
    final className = classes
        .map((it) => it.trim().toLowerCase())
        .where(options.classesToPreserve.contains)
        .join(' ');

    if (className.isNotEmpty) {
      attributes['class'] = className;
    } else {
      attributes.remove('class');
    }

    for (var it in children) {
      it.cleanClasses(options);
    }
  }
}
