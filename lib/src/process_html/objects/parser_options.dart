/// The configuration which can be passed to the main entry point, for creating
/// readable HTML.
class ParserOptions {
  /// Set to true if you wish to bypass jsonLd parsing
  final bool disableJsonLd;

  /// Limits the total amount of top readability candidates within a Document
  final int nTopCandidates;

  /// The threshold for ignoring text outside of this value
  final int charThreshold;

  /// A List of classes which shouldn't be stripped
  final List<String> classesToPreserve;

  /// The base url, which is used to transform relative resources into absolute resources
  final Uri? baseUri;

  /// Creates an instance which contains various parser settings.
  /// These determine the way readability transforms the original HTML.
  const ParserOptions({
    this.disableJsonLd = true,
    this.nTopCandidates = 5,
    this.charThreshold = 500,
    this.classesToPreserve = const ['page'],
    this.baseUri,
  });
}
