import 'package:flutter/widgets.dart';

import 'package:collection/collection.dart';

/// This controller allows manipulating and navigating through the history stack
/// of the reader mode instance.
class ReaderModeController extends ChangeNotifier {
  final List<UriWithScrollPosition> _entries = <UriWithScrollPosition>[];
  UriWithScrollPosition? _uriAndPosition;
  int _index = 0, _previousIndex = 0;

  /// Returns a list containing the current history
  Iterable<UriWithScrollPosition> get entries =>
      List<UriWithScrollPosition>.unmodifiable(_entries);

  /// Returns the current [Uri]
  Uri? get uri => _uriAndPosition?.uri;

  /// Returns the last known scroll position for the current [Uri]
  double get position => _uriAndPosition?.position ?? .0;

  /// Returns the index of the current loaded [Uri]
  int get entryIndex => _index;

  /// Returns true, if a previous [Uri] is available
  bool get canGoBack => _index > 0;

  /// Returns true, if a next [Uri] is available
  bool get canGoForward => _index < _entries.length - 1;

  /// Returns the last known scroll position for the [uri].
  /// If the [uri] does not match any known Uris, then a scroll offset of zero is returned.
  double positionForUri(Uri uri) =>
      _entries.firstWhereOrNull((it) => it.uri == uri)?.position ?? .0;

  /// Pushes a new [Uri] into the inner stack and immediately sets the current
  /// [entryIndex] to this new [Uri].
  bool loadUri(Uri uri, {double position = 0.0}) {
    final uriAndPosition = UriWithScrollPosition(
      uri: uri,
      position: position,
    );

    if (uriAndPosition.toString() == _uriAndPosition.toString()) {
      return false;
    }

    _uriAndPosition = uriAndPosition;

    for (var i = _entries.length - 1; i >= _index + 1; i--) {
      _entries.removeAt(i);
    }

    _entries.add(uriAndPosition);
    _previousIndex = _index;
    _index = _entries.length - 1;

    notifyListeners();

    return true;
  }

  /// Stores a scroll offset value for the previous [Uri]
  void setScrollPositionForPreviousIndex(Uri uri, double value) {
    _entries[_previousIndex] = UriWithScrollPosition(uri: uri, position: value);
  }

  /// Stores a scroll offset value for the current [Uri]
  void updateScrollPositionForCurrentIndex(double value) {
    if (_uriAndPosition != null) {
      _uriAndPosition = _uriAndPosition!.copyWith(position: value);
      _entries[_index] = _uriAndPosition!;
    }
  }

  /// A handler which allows overwriting the current history.
  /// It is however impossible to remove the current [uri], you may only
  /// overwrite previous and next history entries, relative to the current [uri].
  /// After this method completes, the [entryIndex] will be set to the entry which
  /// contains the current [uri].
  void overwrite(
      {Iterable<Uri> back = const <Uri>[],
      Iterable<Uri> forward = const <Uri>[]}) {
    final currentUri = _entries[_index];

    _entries
      ..clear()
      ..addAll(back.map((it) => UriWithScrollPosition.initial(it)))
      ..add(currentUri)
      ..addAll(forward.map((it) => UriWithScrollPosition.initial(it)));

    _index = _previousIndex = _entries.length - forward.length - 1;

    notifyListeners();
  }

  /// Clears the history, leaving the current [uri] as the only entry.
  /// After this method completes, the [entryIndex] will be reset.
  void clear() {
    final currentUri = _entries[_index];

    _entries
      ..clear()
      ..add(currentUri);

    _previousIndex = 0;
    _index = 0;

    notifyListeners();
  }

  /// Allows stepping into the history entries by [toIndex] amount of steps.
  /// This is similar to the History.go interface as found in browsers.
  bool go(int toIndex) {
    if (toIndex < 0 || toIndex > _entries.length - 1) {
      return false;
    }

    _previousIndex = _index;
    _index = toIndex;
    _uriAndPosition = _entries[_index];

    notifyListeners();

    return true;
  }

  /// If [canGoBack] is true, then this method will go back one entry in the
  /// current history stack.
  bool back() {
    if (!canGoBack) {
      return false;
    }

    _previousIndex = _index;
    _index--;
    _uriAndPosition = _entries[_index];

    notifyListeners();

    return true;
  }

  /// If [canGoForward] is true, then this method will go forward one entry in the
  /// current history stack.
  bool forward() {
    if (!canGoForward) {
      return false;
    }

    _previousIndex = _index;
    _index++;
    _uriAndPosition = _entries[_index];

    notifyListeners();

    return true;
  }
}

/// Tuple class containing the [position] for a given [uri].
class UriWithScrollPosition {
  /// The url that was loaded
  final Uri uri;

  /// The last position in the scrollable body
  final double position;

  /// Creates a new tuple
  const UriWithScrollPosition({
    required this.uri,
    required this.position,
  });

  /// Creates a new tuple from the starting position of zero
  const UriWithScrollPosition.initial(this.uri) : position = 0;

  /// Clones this tuple with different values
  UriWithScrollPosition copyWith({double? position}) => UriWithScrollPosition(
        uri: uri,
        position: position ?? this.position,
      );

  @override
  String toString() => uri.toString();
}
