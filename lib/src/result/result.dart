import 'dart:async';
import 'package:api_gen/src/exception/exception.dart';

sealed class Result<T> {
  const Result();

  /// successful result
  const factory Result.success(T value) = Success<T>;

  /// failed result
  const factory Result.failure(ApiGenException exception) = Failure<T>;

  /// successful result checker
  bool get isSuccessful => this is Success<T>;

  /// check if result is a failure
  bool get isFailure => this is Failure<T>;

  /// Map the success value to a new type
  Result<U> map<U>(U Function(T value) mapper) {
    return switch (this) {
      Success<T>(value: final value) => Result.success(mapper(value)),
      Failure<T>(exception: final exception) => Result.failure(exception),
    };
  }

  /// Handle both success and failure cases
  U fold<U>(
    U Function(T value) onSuccess,
    U Function(ApiGenException exception) onFailure,
  ) {
    return switch (this) {
      Success<T>(value: final value) => onSuccess(value),
      Failure<T>(exception: final exception) => onFailure(exception),
    };
  }

  /// Helper to run a function and capture exceptions as Result
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

final class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);
}

final class Failure<T> extends Result<T> {
  final ApiGenException exception;

  const Failure(this.exception);
}
