import 'dart:async';
import 'package:api_gen/src/exception/exception.dart';

/// Represents the result of an operation, which can be either a [Success] or [Failure].
///
/// Used throughout the api_gen package to indicate success or failure of operations,
/// and to propagate errors in a type-safe way.
sealed class Result<T> {
  /// Creates a [Result].
  const Result();

  /// Creates a successful result containing [value].
  const factory Result.success(T value) = Success<T>;

  /// Creates a failed result containing an [ApiGenException].
  const factory Result.failure(ApiGenException exception) = Failure<T>;

  /// Returns `true` if this result is a [Success].
  bool get isSuccessful => this is Success<T>;

  /// Returns `true` if this result is a [Failure].
  bool get isFailure => this is Failure<T>;

  /// Maps the success value to a new type using [mapper].
  /// If this is a [Failure], the exception is propagated.
  Result<U> map<U>(U Function(T value) mapper) {
    return switch (this) {
      Success<T>(value: final value) => Result.success(mapper(value)),
      Failure<T>(exception: final exception) => Result.failure(exception),
    };
  }

  /// Handles both success and failure cases.
  /// Calls [onSuccess] if this is a [Success], or [onFailure] if this is a [Failure].
  U fold<U>(
    U Function(T value) onSuccess,
    U Function(ApiGenException exception) onFailure,
  ) {
    return switch (this) {
      Success<T>(value: final value) => onSuccess(value),
      Failure<T>(exception: final exception) => onFailure(exception),
    };
  }

  /// Runs a function [fn] and captures exceptions as a [Result].
  /// Returns [Result.success] if [fn] completes without error, otherwise [Result.failure].
  static Future<Result<T>> guard<T>(FutureOr<T> Function() fn) async {
    try {
      final value = await fn();
      return Result.success(value);
    } on ApiGenException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(CodeGenerationException('Unknown error', e));
    }
  }
}

/// Represents a successful [Result] containing a value of type [T].
final class Success<T> extends Result<T> {
  /// The value of the successful result.
  final T value;

  /// Creates a [Success] result with the given [value].
  const Success(this.value);
}

/// Represents a failed [Result] containing an [ApiGenException].
final class Failure<T> extends Result<T> {
  /// The exception associated with the failure.
  final ApiGenException exception;

  /// Creates a [Failure] result with the given [exception].
  const Failure(this.exception);
}
