/// An extension on [String] to facilitate parsing
extension StringIsValidByLineExtension on String {
  /// Evaluates a [String] to see if it passes as a byLine
  bool get isValidByline {
    final byline = trim();

    return byline.isNotEmpty && (byline.length < 100);
  }
}
