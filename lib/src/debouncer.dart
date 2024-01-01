import 'dart:async';

/// A simple utility class for debouncing function calls.
///
/// Use the [Debouncer] to delay and combine multiple function calls into a
/// single call after a specified delay. This can be useful for scenarios where
/// you want to avoid invoking a function too frequently, such as handling user
/// input or network requests.
class Debouncer {
  /// Creates a [Debouncer] instance with the specified [delay].
  ///
  /// The [delay] defines the duration to wait before invoking the callback
  /// after the last debounce request. It should be a positive duration.
  Debouncer({required this.delay});

  /// The delay duration for debouncing in milliseconds.
  final Duration delay;
  Timer? _timer;

  /// Debounces a callback function by canceling any existing timer and
  /// scheduling the callback after the defined [delay].
  ///
  /// The [callback] is the function to be debounced. It will be called after
  /// waiting for the specified [delay] duration after the last debounce
  /// request. Any previously scheduled debounced calls will be canceled.
  void debounce(void Function() callback) {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(delay, callback);
  }
}
