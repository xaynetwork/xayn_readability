import 'dart:math';

import 'package:html/dom.dart' as dom;

/// An extension on [dom.Element] to facilitate parsing
extension ElementRowColumnCountExtension on dom.Element {
  /// Calculates how many rows and columns exist within table rows,
  /// then returns the values in a [RowsAndColumns] tuple.
  RowsAndColumns get rowAndColumnCount {
    var rows = 0;
    var columns = 0;
    final trs = getElementsByTagName('tr');

    for (var i = 0, len = trs.length; i < len; i++) {
      final rowSpan =
          int.tryParse(trs[i].attributes['rowspan'] ?? '0', radix: 10);

      rows += rowSpan ?? 1;

      // Now look for column-related info
      var columnsInThisRow = 0;
      final cells = trs[i].getElementsByTagName('td');

      for (var j = 0, len2 = cells.length; j < len2; j++) {
        final colSpan =
            int.tryParse(cells[j].attributes['colspan'] ?? '0', radix: 10);

        columnsInThisRow += colSpan ?? 1;
      }
      columns = max(columns, columnsInThisRow);
    }

    return RowsAndColumns(rows: rows, cols: columns);
  }
}

/// Tuple containing the amount of [rows] and [cols] in a Table Element
class RowsAndColumns {
  /// table rows
  final int rows;

  /// table columns
  final int cols;

  /// Constructs a new tuple holding [rows] and [cols]
  const RowsAndColumns({required this.rows, required this.cols});
}
