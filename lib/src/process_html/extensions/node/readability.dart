import 'package:html/dom.dart' as dom;

final Map<dom.Node, Readability> _readability = <dom.Node, Readability>{};
final Map<dom.Node, bool> _readabilityDataTable = <dom.Node, bool>{};

/// An extension on [dom.Node] to facilitate parsing
extension NodeReadabilityExtension on dom.Node {
  /// Returns true if readability was found for this [dom.Node]
  bool get hasReadability => _readability.containsKey(this);

  /// Returns true if this [dom.Node] is a TableElement value
  bool? resolveDataTableValue(dom.Node? node) =>
      node != null ? _readabilityDataTable[node] : false;

  /// Marks the [node] as TableElement value using [value]
  void updateDataTableValue(bool value) => _readabilityDataTable[this] = value;

  /// Returns the readability score for this [dom.Node]
  double get readabilityContentScore =>
      (_readability[this] ?? const Readability()).contentScore;

  /// Sets the readability score for this [dom.Node]
  void setReadabilityContentScore(double value) {
    var readability = _readability[this] ?? const Readability();

    readability = readability.withContentScore(value);

    _readability[this] = readability;
  }
}

/// A class which contains the readability value, as a number
class Readability {
  /// The readability, calculated value
  final double contentScore;

  Readability._(this.contentScore);

  /// The default constructor, sets the initial [contentScore] to zero
  const Readability() : contentScore = .0;

  /// Returns an updated [Readability] object with a different [contentScore]
  Readability withContentScore(double value) => Readability._(value);
}
