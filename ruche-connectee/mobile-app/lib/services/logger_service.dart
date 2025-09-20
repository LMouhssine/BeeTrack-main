import 'package:logger/logger.dart';
import 'package:ruche_connectee/config/logging_config.dart';

class LoggerService {
  static final Logger _logger = Logger(
    level: LoggingConfig.productionMode ? Level.warning : Level.info,
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTime,
      noBoxingByDefault: true,
      excludeBox: {
        Level.trace: true,
        Level.fatal: true,
        Level.debug: true,
      },
    ),
  );

  static void debug(String message) {
    if (LoggingConfig.enableDebugLogs) {
      _logger.d(message);
    }
  }

  static void info(String message) {
    if (LoggingConfig.productionMode) {
      // En production, limiter les logs info
      if (message.contains('💡') || message.contains('✅')) {
        _logger.i(message);
      }
    } else {
      _logger.i(message);
    }
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void trace(String message) {
    if (LoggingConfig.enableTraceLogs) {
      _logger.t(message);
    }
  }

  static void fatal(String message) {
    _logger.f(message);
  }
}
