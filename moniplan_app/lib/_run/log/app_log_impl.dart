// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:logging/logging.dart';
import 'package:moniplan_core/moniplan_core.dart';

class MoniplanLog implements AppLog {
  final Logger _logger;

  MoniplanLog({
    required Logger logger,
  }) : _logger = logger;

  @override
  void business(Object? msg) {
    _logger.info(msg);
  }

  @override
  void critical(Object? msg, {Object? error, StackTrace? trace}) {
    _logger.shout(msg, error, trace);
  }

  @override
  void debug(Object? msg, {bool trace = false, bool sentry = false}) {
    _logger.fine(msg, trace ? StackTrace.current : null);
  }

  @override
  void error(Object? msg, {Object? error, StackTrace? trace}) {
    _logger.severe(msg, error, trace);
  }

  @override
  void network(
    Object? msg, {
    Object? error,
    StackTrace? trace,
    String? method,
    int? statusCode,
    String? url,
  }) {
    // TODO: implement network
  }

  @override
  void trace(Object? msg, {bool trace = false}) {
    _logger.finest(msg, trace ? StackTrace.current : null);
  }

  @override
  void warning(Object? msg, {bool trace = false, bool sentry = false}) {
    _logger.warning(msg, trace ? StackTrace.current : null);
  }
}
