import 'dart:math' as math;

extension StringExtension on String {
  /// Capitalize first letter of string
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Check if string is valid email
  bool isValidEmail() {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(this);
  }

  /// Check if string is valid phone number
  bool isValidPhone() {
    return RegExp(r'^(\+\d{1,3})?\d{9,15}$').hasMatch(this);
  }

  /// Check if string is strong password
  bool isStrongPassword() {
    return length >= 8 &&
        contains(RegExp(r'[a-z]')) &&
        contains(RegExp(r'[A-Z]')) &&
        contains(RegExp(r'[0-9]')) &&
        contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  /// Remove all whitespace
  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Truncate string with ellipsis
  String truncate(int length, {String ellipsis = '...'}) {
    return this.length > length
        ? '${substring(0, length)}$ellipsis'
        : this;
  }

  /// Add leading zeros
  String addLeadingZeros(int length) {
    return padLeft(length, '0');
  }
}

extension IntExtension on int {
  /// Add leading zeros to int
  String addLeadingZeros(int length) {
    return toString().padLeft(length, '0');
  }
}

extension DoubleExtension on double {
  /// Round to specific decimal places
  double roundToDecimals(int decimals) {
    final multiplier = math.pow(10, decimals).toDouble();
    return (this * multiplier).round() / multiplier;
  }

  /// Format as currency
  String toCurrency({String symbol = '\$'}) {
    return '$symbol${toStringAsFixed(2)}';
  }
}

extension ListExtension<T> on List<T> {
  /// Get random element
  T? getRandomElement() {
    if (isEmpty) return null;
    return this[(DateTime.now().millisecondsSinceEpoch % length)];
  }

  /// Duplicate list
  List<T> duplicate() {
    return List<T>.from(this);
  }
}

extension MapExtension<K, V> on Map<K, V> {
  /// Check if map is empty or null
  bool get isEmpty => this.isEmpty;

  /// Check if map is not empty
  bool get isNotEmpty => this.isNotEmpty;

  /// Get value safely
  V? getSafe(K key) {
    return containsKey(key) ? this[key] : null;
  }
}
