import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/foundation.dart' show kDebugMode;

class ShowingLogCondition {
  static const bool always = true; // always show log
  static const bool never = false; // never show log
  static const bool inDebug = kDebugMode; // show log in Degug mode only
  static const bool inRelease = kReleaseMode; // show log in Release mode only
}

// Set level for showing log
class ErrorFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return event.level == Level.debug ||
        event.level == Level.info ||
        event.level == Level.error ||
        event.level == Level.warning;
  }
}

class CustomLogger {
  // You MUST set condition to show log or not
  bool isShow = ShowingLogCondition.always;

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      colors: true,
      printEmojis: true,
      noBoxingByDefault: true,
      printTime: false,
      methodCount: 0, // set 0 / 2 to hide/show file where log
      lineLength: 50,
    ),
    filter: ErrorFilter(),
  );

  void verbose(String message) {
    if (isShow) _logger.t(message);
  }

  void debug(String message) {
    if (isShow) _logger.d(message);
  }

  void info(String message) {
    if (isShow) _logger.i(message);
  }

  void warning(String message) {
    if (isShow) _logger.w(message);
  }

  void error(String message) {
    if (isShow) _logger.e(message);
  }

  void fatal(String message) {
    _logger.f(message);
  }
}
