enum LogLevel { debug, info, warning, error }

class Logger {
  Logger(this.name, [this.level = LogLevel.info]);

  final String name;
  final LogLevel level;

  void debug(String message) => _log(LogLevel.debug, message);
  void info(String message) => _log(LogLevel.info, message);
  void warning(String message) => _log(LogLevel.warning, message);
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message);
    if (error != null) {
      _log(LogLevel.error, 'Error details: $error');
    }
    if (stackTrace != null) {
      _log(LogLevel.error, 'Stack trace: $stackTrace');
    }
  }

  void _log(LogLevel level, String message) {
    if (level.index >= this.level.index) {
      final timestamp = DateTime.now().toIso8601String();
      final levelStr = level.name.toUpperCase().padRight(7);
      print('$timestamp [$levelStr] $name: $message');
    }
  }
}
