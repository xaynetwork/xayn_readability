import 'package:xayn_readability_core/xayn_readability_core.dart';

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

  /// The link to the favicon
  final String? favicon;

  /// The link to an embedded video, if any
  final Uri? video;

  /// Constructor to create a new [ProcessHtmlResult] with values.
  const ProcessHtmlResult({
    required this.themeColor,
    this.favicon,
    this.contents,
    this.lang,
    this.description,
    this.title,
    this.author,
    this.metadata,
    this.video,
    int? textSize,
  }) : textSize = textSize ?? 0;

  /// Returns a modified [ProcessHtmlResult], with other [contents] and/or [textSize].
  ProcessHtmlResult withOtherContent(String? contents, {int? textSize}) =>
      ProcessHtmlResult(
        contents: contents,
        favicon: favicon,
        lang: lang,
        themeColor: themeColor,
        description: description,
        title: title,
        author: author,
        metadata: metadata,
        textSize: textSize ?? this.textSize,
        video: video,
      );
}
