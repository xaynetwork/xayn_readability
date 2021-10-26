import 'dart:math';

import 'package:html/dom.dart' as dom;

/// An extension on [dom.Element] to facilitate parsing
extension ElementRowColumnCountExtension on dom.Element {
  /// Calculates how many rows and columns exist within table rows,
  /// then returns the values in a [_RowsAndColumns] tuple.
  _RowsAndColumns get rowAndColumnCount {
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

    return _RowsAndColumns(rows: rows, cols: columns);
  }
}

class _RowsAndColumns {
  final int rows, cols;

  const _RowsAndColumns({required this.rows, required this.cols});
}
