abstract class ApiGenException implements Exception {
  final String message;
  final Object? cause;

  const ApiGenException(this.message, [this.cause]);

  @override
  String toString() =>
      'ApiGenException: $message${cause != null ? ' (Caused by: $cause)' : ''}';
}

/// Schema validation errors

class SchemaValidationException extends ApiGenException {
  const SchemaValidationException(super.message, [super.cause]);

  @override
  String toString() => 'SchemaValidationException: $message';
}

/// File I/O related errors
class FileOperationException extends ApiGenException {
  const FileOperationException(super.message, [super.cause]);

  @override
  String toString() => 'FileOperationException: $message';
}

/// Code generation errors
class CodeGenerationException extends ApiGenException {
  const CodeGenerationException(super.message, [super.cause]);

  @override
  String toString() => 'CodeGenerationException: $message';
}

/// JSON parsing errors
class JsonParsingException extends ApiGenException {
  const JsonParsingException(super.message, [super.cause]);

  @override
  String toString() => 'JsonParsingException: $message';
}
