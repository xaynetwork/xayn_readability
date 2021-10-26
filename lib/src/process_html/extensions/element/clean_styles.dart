import 'package:html/dom.dart' as dom;

/// An extension on [dom.Element] to facilitate parsing
extension ElementCleanStylesExtension on dom.Element {
  /// Swipes through any styles that are not applicable for reader mode
  void cleanStyles() {
    if (localName?.toLowerCase() == 'svg') {
      return;
    }

    const presentationalAttributes = [
      'align',
      'background',
      'bgcolor',
      'border',
      'cellpadding',
      'cellspacing',
      'frame',
      'hspace',
      'rules',
      'style',
      'valign',
      'vspace'
    ];
    const deprecatedSizeAttributeElms = ['TABLE', 'TH', 'TD', 'HR', 'PRE'];

    // Remove `style` and deprecated presentational attributes
    for (var i = 0, len = presentationalAttributes.length; i < len; i++) {
      attributes.remove(presentationalAttributes[i]);
    }

    if (deprecatedSizeAttributeElms.contains(localName?.toUpperCase())) {
      attributes.remove('width');
      attributes.remove('height');
    }

    var cur = children.isNotEmpty ? children.first : null;

    while (cur != null) {
      cur.cleanStyles();
      cur = cur.nextElementSibling;
    }
  }
}
