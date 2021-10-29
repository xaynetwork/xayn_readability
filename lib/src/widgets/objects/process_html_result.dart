import 'package:xayn_readability/src/process_html/steps/get_json_ld.dart';

/// A class which contains all output of an operation which transformed original HTML into readable HTML
class ProcessHtmlResult {
  /// The readable HTML
  final String? contents;

  /// The language that was found in the original Document
  final String? lang;

  /// The total text size of [contents]
  final int textSize;

  /// The discovered theme color in the original Document
  final int themeColor;

  /// The description that was found in the original Document
  final String? description;

  /// The title that was found in the original Document
  final String? title;

  /// The author that was found in the original Document
  final String? author;

  /// The metadata that was found in the original Document
  final Metadata? metadata;

  /// Constructor to create a new [ProcessHtmlResult] with values.
  const ProcessHtmlResult({
    this.contents,
    this.lang,
    required this.themeColor,
    this.description,
    this.title,
    this.author,
    this.metadata,
    int? textSize,
  }) : textSize = textSize ?? 0;

  /// Returns a modified [ProcessHtmlResult], with other [contents] and/or [textSize].
  ProcessHtmlResult withOtherContent(String? contents, {int? textSize}) =>
      ProcessHtmlResult(
        contents: contents,
        lang: lang,
        themeColor: themeColor,
        description: description,
        title: title,
        author: author,
        metadata: metadata,
        textSize: textSize ?? this.textSize,
      );
}
