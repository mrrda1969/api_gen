/// The base exception type for all errors thrown by the api_gen package.
///
/// Contains a [message] describing the error and an optional [cause].
abstract class ApiGenException implements Exception {
  final String message;
  final Object? cause;

  const ApiGenException(this.message, [this.cause]);

  @override
  String toString() =>
      'ApiGenException: $message${cause != null ? ' (Caused by: $cause)' : ''}';
}

/// Exception thrown when schema validation fails.
class SchemaValidationException extends ApiGenException {
  const SchemaValidationException(super.message, [super.cause]);

  @override
  String toString() => 'SchemaValidationException: $message';
}

/// Exception thrown for file I/O related errors.
class FileOperationException extends ApiGenException {
  const FileOperationException(super.message, [super.cause]);

  @override
  String toString() => 'FileOperationException: $message';
}

/// Exception thrown for code generation errors.
class CodeGenerationException extends ApiGenException {
  const CodeGenerationException(super.message, [super.cause]);

  @override
  String toString() => 'CodeGenerationException: $message';
}

/// Exception thrown for JSON parsing errors.
class JsonParsingException extends ApiGenException {
  const JsonParsingException(super.message, [super.cause]);

  @override
  String toString() => 'JsonParsingException: $message';
}
