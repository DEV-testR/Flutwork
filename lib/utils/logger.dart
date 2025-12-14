import 'package:logger/logger.dart';

/// Global logger instance with stack trace
final logger = Logger(printer: PrettyPrinter());

/// Global logger instance without stack trace
final loggerNoStack = Logger(printer: PrettyPrinter(methodCount: 0));

