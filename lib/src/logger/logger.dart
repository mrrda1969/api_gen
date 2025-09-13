/// The severity level for log messages.
enum LogLevel {
  /// Debug-level messages, typically used for development and troubleshooting.
  debug,

  /// Informational messages that highlight the progress of the application.
  info,

  /// Warning messages indicating a potential issue or important event.
  warning,

  /// Error messages indicating a failure or problem.
  error,
}

/// A simple logger for printing messages with different severity levels.
///
/// The [Logger] supports debug, info, warning, and error levels. Each log message
/// includes a timestamp, log level, logger name, and the message content.
class Logger {
  /// Creates a [Logger] with the given [name] and optional [level].
  ///
  /// The [level] determines the minimum severity that will be logged.
  Logger(this.name, [this.level = LogLevel.info]);

  /// The name of the logger, typically used to identify the source.
  final String name;

  /// The minimum [LogLevel] that will be logged.
  final LogLevel level;

  /// Logs a debug-level [message].
  void debug(String message) => _log(LogLevel.debug, message);

  /// Logs an info-level [message].
  void info(String message) => _log(LogLevel.info, message);

  /// Logs a warning-level [message].
  void warning(String message) => _log(LogLevel.warning, message);

  /// Logs an error-level [message], with optional [error] details and [stackTrace].
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message);
    if (error != null) {
      _log(LogLevel.error, 'Error details: $error');
    }
    if (stackTrace != null) {
      _log(LogLevel.error, 'Stack trace: $stackTrace');
    }
  }

  /// Internal method to print a log [message] if its [level] is enabled.
  void _log(LogLevel level, String message) {
    if (level.index >= this.level.index) {
      final timestamp = DateTime.now().toIso8601String();
      final levelStr = level.name.toUpperCase().padRight(7);
      print('$timestamp [$levelStr] $name: $message');
    }
  }
}
