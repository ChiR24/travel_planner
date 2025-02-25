import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

/// Types of errors that can occur in the app
enum ErrorType {
  /// Network-related errors (connectivity, timeouts, etc.)
  network,

  /// Authentication errors (invalid credentials, expired tokens, etc.)
  authentication,

  /// Authorization errors (insufficient permissions, etc.)
  authorization,

  /// Validation errors (invalid input, etc.)
  validation,

  /// Server errors (internal server errors, etc.)
  server,

  /// Client errors (bugs in the app, etc.)
  client,

  /// Unknown errors
  unknown
}

/// A model representing an application error
class AppError {
  /// The type of error
  final ErrorType type;

  /// The error message
  final String message;

  /// The original exception or error
  final dynamic exception;

  /// The stack trace
  final StackTrace? stackTrace;

  /// Whether the error has been handled
  bool isHandled = false;

  /// Creates an application error
  AppError({
    required this.type,
    required this.message,
    this.exception,
    this.stackTrace,
  });

  /// Creates a network error
  factory AppError.network(dynamic exception,
      {String? message, StackTrace? stackTrace}) {
    return AppError(
      type: ErrorType.network,
      message: message ?? _getNetworkErrorMessage(exception),
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  /// Creates an authentication error
  factory AppError.authentication(dynamic exception,
      {String? message, StackTrace? stackTrace}) {
    return AppError(
      type: ErrorType.authentication,
      message: message ?? 'Authentication failed. Please sign in again.',
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  /// Creates an authorization error
  factory AppError.authorization(dynamic exception,
      {String? message, StackTrace? stackTrace}) {
    return AppError(
      type: ErrorType.authorization,
      message: message ?? 'You do not have permission to perform this action.',
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  /// Creates a validation error
  factory AppError.validation(dynamic exception,
      {String? message, StackTrace? stackTrace}) {
    return AppError(
      type: ErrorType.validation,
      message:
          message ?? 'Invalid input. Please check your data and try again.',
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  /// Creates a server error
  factory AppError.server(dynamic exception,
      {String? message, StackTrace? stackTrace}) {
    return AppError(
      type: ErrorType.server,
      message: message ?? 'Server error. Please try again later.',
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  /// Creates a client error
  factory AppError.client(dynamic exception,
      {String? message, StackTrace? stackTrace}) {
    return AppError(
      type: ErrorType.client,
      message: message ?? 'An unexpected error occurred. Please try again.',
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  /// Creates an unknown error
  factory AppError.unknown(dynamic exception,
      {String? message, StackTrace? stackTrace}) {
    return AppError(
      type: ErrorType.unknown,
      message: message ?? 'An unknown error occurred. Please try again.',
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  /// Gets a user-friendly message for network errors
  static String _getNetworkErrorMessage(dynamic exception) {
    if (exception is SocketException || exception is TimeoutException) {
      return 'Network connection error. Please check your internet connection and try again.';
    } else {
      return 'Network error. Please try again.';
    }
  }

  /// Marks the error as handled
  void markAsHandled() {
    isHandled = true;
  }

  @override
  String toString() {
    return 'AppError{type: $type, message: $message, exception: $exception}';
  }
}

/// A centralized error handler for the application
class AppErrorHandler {
  /// Handles an error and returns an AppError
  static AppError handleError(dynamic error, {StackTrace? stackTrace}) {
    // Log the error
    developer.log(
      'Error: $error',
      error: error,
      stackTrace: stackTrace,
      name: 'AppErrorHandler',
    );
    if (stackTrace != null) {
      developer.log(
        'StackTrace: $stackTrace',
        error: error,
        stackTrace: stackTrace,
        name: 'AppErrorHandler',
      );
    }

    // Create an AppError based on the type of error
    AppError appError;

    if (error is SocketException || error is TimeoutException) {
      appError = AppError.network(error, stackTrace: stackTrace);
    } else if (error is AppError) {
      // If it's already an AppError, just return it
      appError = error;
    } else {
      // Default to unknown error
      appError = AppError.unknown(error, stackTrace: stackTrace);
    }

    return appError;
  }

  /// Shows an error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    AppError error,
  ) async {
    error.markAsHandled();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_getErrorTitle(error.type)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(error.message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows an error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    AppError error,
  ) {
    error.markAsHandled();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: _getErrorColor(error.type),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Gets a title for an error type
  static String _getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Network Error';
      case ErrorType.authentication:
        return 'Authentication Error';
      case ErrorType.authorization:
        return 'Authorization Error';
      case ErrorType.validation:
        return 'Validation Error';
      case ErrorType.server:
        return 'Server Error';
      case ErrorType.client:
        return 'Application Error';
      case ErrorType.unknown:
        return 'Error';
    }
  }

  /// Gets a color for an error type
  static Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.authentication:
        return Colors.red.shade800;
      case ErrorType.authorization:
        return Colors.red.shade700;
      case ErrorType.validation:
        return Colors.amber.shade700;
      case ErrorType.server:
        return Colors.red;
      case ErrorType.client:
        return Colors.purple;
      case ErrorType.unknown:
        return Colors.red.shade900;
    }
  }
}

/// Provider for the current app error
final appErrorProvider = StateProvider<AppError?>((ref) => null);

/// Extension on Ref to handle errors
extension ErrorHandlingRef on Ref {
  /// Sets the current error
  void setError(AppError error) {
    read(appErrorProvider.notifier).state = error;
  }

  /// Clears the current error
  void clearError() {
    read(appErrorProvider.notifier).state = null;
  }

  /// Handles an error and sets it as the current error
  AppError handleError(dynamic error, {StackTrace? stackTrace}) {
    final appError = AppErrorHandler.handleError(error, stackTrace: stackTrace);
    setError(appError);
    return appError;
  }
}

/// Widget that listens for errors and shows them
class AppErrorListener extends ConsumerWidget {
  /// The child widget
  final Widget child;

  /// Whether to show errors as dialogs
  final bool showAsDialog;

  /// Creates an error listener widget
  const AppErrorListener({
    Key? key,
    required this.child,
    this.showAsDialog = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(appErrorProvider);

    // Show error if it exists and hasn't been handled
    if (error != null && !error.isHandled) {
      // Use a post-frame callback to avoid build phase errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (showAsDialog) {
          AppErrorHandler.showErrorDialog(context, error);
        } else {
          AppErrorHandler.showErrorSnackBar(context, error);
        }
      });
    }

    return child;
  }
}
