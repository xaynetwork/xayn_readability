import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart' as dom;
import 'package:xayn_readability/src/process_html/process_html.dart';
import 'package:xayn_readability/xayn_readability.dart';

// todo: update tests to match expected.html instead of generated.html
// the problem is the different html formatting, so we would need to deep-match
// output vs expected
void main() {
  group('Test pages', () {
    final pathSplitterExp = RegExp(r'[\/\\]+');
    final pages = Directory('./test/test_pages');
    final pageDirs = pages.listSync().cast<Directory>();

    /*sanitizeHtml(String html) {
      final doc = dom.Document.html(html
          .replaceAll(RegExp(r'http://fakehost[/]*'), '')
          .replaceAll(RegExp(r'[\r\n ]+'), ''));

      return doc.outerHtml;
    }*/

    setUp(() {
      // Additional setup goes here.
    });

    for (var it in pageDirs) {
      final assets = it.listSync().cast<File>();
      var source = '', expected = '';

      for (var it in assets) {
        final assetName = it.path.split(pathSplitterExp).last;

        switch (assetName) {
          case 'source.html':
            source = it.readAsStringSync();
            break;
          case 'generated.html':
            expected = it.readAsStringSync();
            break;
        }
      }

      test(it.path.split(pathSplitterExp).last, () {
        final parsed = parse(dom.Document.html(source));

        //File('${it.path}/generated.html').writeAsStringSync(parsed!.html);

        expect(parsed!.html, expected);
      });
    }
  });
}
