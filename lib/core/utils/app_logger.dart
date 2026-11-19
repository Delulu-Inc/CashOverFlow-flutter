import 'package:flutter/foundation.dart';

/// Thin logging facade.
///
/// Logs are only emitted in debug builds so that production consoles never
/// leak API payloads (tokens, personal data, ...).
abstract final class AppLogger {
  static void debug(String message) {
    if (kDebugMode) debugPrint('[CashOverflow] $message');
  }

  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint(
        '[CashOverflow][ERROR] $message${error != null ? ' → $error' : ''}',
      );
    }
  }
}
