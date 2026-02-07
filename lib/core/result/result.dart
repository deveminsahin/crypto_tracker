import 'package:crypto_tracker/core/errors/app_exception.dart';

/// A discriminated union representing either a successful value or a failure.
///
/// Use Dart 3 pattern matching for exhaustive handling:
/// ```dart
/// switch (result) {
///   case Success(:final data): handleData(data);
///   case Failure(:final exception): handleError(exception);
/// }
/// ```
///
/// Or the convenience methods [map] and [when]:
/// ```dart
/// final names = result.map((tickers) => tickers.map((t) => t.symbol));
/// final message = result.when(
///   success: (data) => 'Loaded ${data.length} items',
///   failure: (e) => e.message,
/// );
/// ```
sealed class Result<T> {
  const Result();

  /// Transforms the [Success] value with [transform], passing
  /// [Failure] through unchanged.
  Result<R> map<R>(final R Function(T data) transform) => switch (this) {
    Success(:final data) => Success(transform(data)),
    Failure(:final exception) => Failure(exception),
  };

  /// Collapses both cases into a single return value of type [R].
  R when<R>({
    required final R Function(T data) success,
    required final R Function(AppException exception) failure,
  }) => switch (this) {
    Success(:final data) => success(data),
    Failure(:final exception) => failure(exception),
  };
}

/// Represents a successful operation carrying [data] of type [T].
final class Success<T> extends Result<T> {
  /// The successful result value.
  final T data;

  const Success(this.data);
}

/// Represents a failed operation carrying an [AppException].
final class Failure<T> extends Result<T> {
  /// The exception describing what went wrong.
  final AppException exception;

  const Failure(this.exception);
}
