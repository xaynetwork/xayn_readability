import 'package:html/dom.dart' as dom;
import 'package:xayn_readability/src/process_html/extensions/extensions.dart';
import 'package:xayn_readability/src/process_html/objects/flag.dart';

final RegExp _shareElementsMatcher =
    RegExp(r'(\b|_)(share|sharedaddy)(\b|_)', caseSensitive: false);

/// Prepares the [element] to become a reader mode article
void prepArticle(
  final dom.Document document,
  final dom.Element element,
  final Uri? baseUri,
  final Flag flag,
) {
  element.cleanStyles();

  // Check for data tables before we continue, to avoid removing items in
  // those tables, which will often be isolated even though they're
  // visually linked to other content-ful elements (text, images, etc.).
  element.markDataTables();

  element.fixLazyImages(document);

  /*if (baseUri != null) {
    element.rewriteSources(document, baseUri);
  }*/

  final tagsToClean = element.querySelectorAll(
      'form, fieldset, object, embed, footer, link, aside, iframe, input, textarea, select, button, table, ul, div');
  final tagsForm = <dom.Element>[],
      tagsFieldSet = <dom.Element>[],
      tagsObject = <dom.Element>[],
      tagsEmbed = <dom.Element>[],
      tagsFooter = <dom.Element>[],
      tagsLink = <dom.Element>[],
      tagsAside = <dom.Element>[],
      tagsIFrame = <dom.Element>[],
      tagsInput = <dom.Element>[],
      tagsTextArea = <dom.Element>[],
      tagsSelect = <dom.Element>[],
      tagsButton = <dom.Element>[],
      tagsTable = <dom.Element>[],
      tagsUL = <dom.Element>[],
      tagsDiv = <dom.Element>[];

  for (final tagToClean in tagsToClean) {
    switch (tagToClean.localName?.toLowerCase()) {
      case 'form':
        tagsForm.add(tagToClean);
        break;
      case 'fieldset':
        tagsFieldSet.add(tagToClean);
        break;
      case 'object':
        tagsObject.add(tagToClean);
        break;
      case 'embed':
        tagsEmbed.add(tagToClean);
        break;
      case 'footer':
        tagsFooter.add(tagToClean);
        break;
      case 'link':
        tagsLink.add(tagToClean);
        break;
      case 'aside':
        tagsAside.add(tagToClean);
        break;
      case 'iframe':
        tagsIFrame.add(tagToClean);
        break;
      case 'input':
        tagsInput.add(tagToClean);
        break;
      case 'textarea':
        tagsTextArea.add(tagToClean);
        break;
      case 'select':
        tagsSelect.add(tagToClean);
        break;
      case 'button':
        tagsButton.add(tagToClean);
        break;
      case 'table':
        tagsTable.add(tagToClean);
        break;
      case 'ul':
        tagsUL.add(tagToClean);
        break;
      case 'div':
        tagsDiv.add(tagToClean);
        break;
    }
  }

  // Clean out junk from the article content
  element.cleanConditionally('form', tagsForm, flag);
  element.cleanConditionally('fieldset', tagsFieldSet, flag);
  element.clean('object', tagsObject);
  element.clean('embed', tagsEmbed);
  element.clean('footer', tagsFooter);
  element.clean('link', tagsLink);
  element.clean('aside', tagsAside);

  // Clean out elements with little content that have "share" in their id/class combinations from final top candidates,
  // which means we don't remove the top candidates even they have "share".

  const shareElementThreshold = 500;

  for (final topCandidate in element.children) {
    topCandidate.cleanMatchedNodes((node, matchString) =>
        _shareElementsMatcher.hasMatch(matchString) &&
        node.text.length < shareElementThreshold);
  }

  element.clean('iframe', tagsIFrame);
  element.clean('input', tagsInput);
  element.clean('textarea', tagsTextArea);
  element.clean('select', tagsSelect);
  element.clean('button', tagsButton);
  element.cleanHeaders(flag);

  // Do these last as the previous stuff may have removed junk
  // that will affect these
  element.cleanConditionally('table', tagsTable, flag);
  element.cleanConditionally('ul', tagsUL, flag);
  element.cleanConditionally('div', tagsDiv, flag);

  // replace H1 with H2 as H1 should be only title that is displayed separately
  final tags = element.querySelectorAll('h1, p, br, table');
  final tagsH1 = tags
      .where((it) => it.localName?.toLowerCase() == 'h1')
      .toList(growable: false);
  final tagsP = tags
      .where((it) => it.localName?.toLowerCase() == 'p')
      .toList(growable: false);
  final tagsBR = tags
      .where((it) => it.localName?.toLowerCase() == 'br')
      .toList(growable: false);
  final tagsRemainingTable = tags
      .where((it) => it.localName?.toLowerCase() == 'table')
      .toList(growable: false);

  for (var i = tagsH1.length - 1; i >= 0; i--) {
    final h1 = tagsH1[i];

    h1.swappedTagName(document, 'h2');
  }

  // Remove extra paragraphs
  element.removeNodes(tagsP, (paragraph, _, __) {
    final tags = paragraph.querySelectorAll('img, embed, object, iframe');

    return tags.isEmpty && paragraph.getInnerText(false).isEmpty;
  });

  for (var br in tagsBR) {
    final next = br.nextElementSibling?.nextElementNode;

    if (next != null && next.localName?.toLowerCase() == 'p') {
      br.remove();
    }
  }

  // Remove single-cell tables
  for (var table in tagsRemainingTable) {
    final tbody = table.hasSingleTag('tbody') ? table.children.first : table;

    if (tbody.hasSingleTag('tr')) {
      final row = tbody.children.first;

      if (row.hasSingleTag('td')) {
        var cell = row.children.first;

        cell = cell.swappedTagName(document,
            cell.children.every((it) => it.isPhrasingContent) ? 'p' : 'div');

        table.replaceWith(cell);
      }
    }
  }
}
