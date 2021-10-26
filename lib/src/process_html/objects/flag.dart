/// A class which keeps track of flags, which are being used while processing html.
class Flag {
  /// The flag value for [stripUnlikely]
  static const int stripUnlikely = 0x1;

  /// The flag value for [weightClasses]
  static const int weightClasses = 0x2;

  /// The flag value for [cleanConditionally]
  static const int cleanConditionally = 0x4;

  int _value;

  /// Creates a new Flag collection and sets all flag values to true upon creation.
  Flag() : _value = stripUnlikely | weightClasses | cleanConditionally;

  /// Returns true if the given [flag] value is currently active
  bool isActive(int flag) => (_value & flag) > 0;

  /// Disables the given [flag], effectively setting it to active = false
  void removeFlag(int flag) => _value &= ~flag;
}
