import 'package:html/dom.dart' as dom;
import 'package:reader_mode/src/process_html/extensions/node_extensions.dart';

import 'row_column_count.dart';

/// An extension on [dom.Element] to facilitate parsing
extension ElementMarkDataTablesExtension on dom.Element {
  /// Scans all TableElements and marks those that are interesting enough
  void markDataTables() {
    final tables = getElementsByTagName('table');

    for (var i = 0, len = tables.length; i < len; i++) {
      final table = tables[i];
      final role = table.attributes['role'];

      if (role == 'presentation') {
        table.updateDataTableValue(false);

        continue;
      }

      final datatable = table.attributes['datatable'];

      if (datatable == '0') {
        table.updateDataTableValue(false);

        continue;
      }

      final summary = table.attributes['summary'];

      if (summary != null) {
        table.updateDataTableValue(true);

        continue;
      }

      final captions = table.getElementsByTagName('caption');
      final caption = captions.isNotEmpty ? captions.first : null;

      if (caption != null && caption.children.isNotEmpty) {
        table.updateDataTableValue(true);

        continue;
      }

      // If the table has a descendant with any of these tags, consider a data table:
      const dataTableDescendants = ['col', 'colgroup', 'tfoot', 'thead', 'th'];
      descendantExists(tag) => table.getElementsByTagName(tag).isNotEmpty;

      if (dataTableDescendants.any(descendantExists)) {
        table.updateDataTableValue(true);

        continue;
      }

      // Nested tables indicate a layout table:
      if (table.getElementsByTagName('table').isNotEmpty) {
        table.updateDataTableValue(false);

        continue;
      }

      final sizeInfo = table.rowAndColumnCount;

      if (sizeInfo.rows >= 10 || sizeInfo.cols > 4) {
        table.updateDataTableValue(true);

        continue;
      }

      // Now just go by size entirely:
      table.updateDataTableValue(sizeInfo.rows * sizeInfo.cols > 10);
    }
  }
}
