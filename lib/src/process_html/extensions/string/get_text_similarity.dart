final RegExp _tokenizeMatcher = RegExp(r'\W+');

/// An extension on [String] to facilitate parsing
extension StringGetTextSimilarityExtension on String {
  /// Calculates the similarity to [other]
  double getTextSimilarity(String other) {
    final tokensA = toLowerCase().split(_tokenizeMatcher).toList();
    final tokensB = other.toLowerCase().split(_tokenizeMatcher).toList();

    if (tokensA.isEmpty || tokensB.isEmpty) {
      return 0;
    }

    final uniqueTokensB = tokensB.where((it) => !tokensA.contains(it));
    final distanceB = uniqueTokensB.join(' ').length / tokensB.join(' ').length;

    return 1.0 - distanceB;
  }
}
