# ApiGen Programmatic Usage Guide

This guide shows how to use the `api_gen` package programmatically in your Dart applications with proper exception handling.

## Quick Start

```dart
import 'package:api_gen/api_gen.dart';

void main() async {
  final client = ApiGenClient();

  // Generate models from a JSON schema file
  final result = await client.generateFromFile('schema.json', 'lib/models');

  if (result.isSuccessful) {
    print('✅ Models generated successfully!');
  } else {
    final failure = result as Failure<void>;
    print('❌ Error: ${failure.exception}');
  }
}
```

## Available Methods

### 1. `generateFromFile()`

Generate models from a JSON schema file.

```dart
final result = await client.generateFromFile(
  'path/to/schema.json',  // Schema file path
  'lib/models',           // Output directory
  useLegacyFormat: true,  // Optional: force legacy format
);
```

### 2. `generateFromSchema()`

Generate models from a schema Map.

```dart
final schema = {
  'User': {
    'id': 'String',
    'name': 'String',
    'email': 'String',
  }
};

final result = await client.generateFromSchema(
  schema,                 // Schema Map
  'lib/models',           // Output directory
  useLegacyFormat: false, // Optional: force standard format
);
```

### 3. `generateFromJsonString()`

Generate models from a JSON string.

```dart
const jsonString = '''
{
  "Product": {
    "id": "String",
    "name": "String",
    "price": "double"
  }
}
''';

final result = await client.generateFromJsonString(
  jsonString,             // JSON string
  'lib/models',           // Output directory
  useLegacyFormat: null,  // Optional: auto-detect format
);
```

## Exception Handling

All methods return a `Result<void>` that you can check for success or failure:

```dart
final result = await client.generateFromFile('schema.json', 'models');

if (result.isSuccessful) {
  // Success case
  print('Models generated successfully!');
} else {
  // Handle error
  final failure = result as Failure<void>;
  final exception = failure.exception;

  if (exception is FileOperationException) {
    print('File error: ${exception.message}');
  } else if (exception is SchemaValidationException) {
    print('Schema error: ${exception.message}');
  } else if (exception is CodeGenerationException) {
    print('Generation error: ${exception.message}');
  } else if (exception is JsonParsingException) {
    print('JSON error: ${exception.message}');
  }
}
```

## Exception Types

The API uses specific exception types for different error scenarios:

- **`FileOperationException`**: File I/O errors (file not found, permission denied, etc.)
- **`SchemaValidationException`**: Invalid or empty schemas
- **`CodeGenerationException`**: Model generation errors
- **`JsonParsingException`**: JSON parsing errors

## Examples

Run the example files to see different usage patterns:

```bash
# Basic usage
dart run example/lib/main.dart

# Comprehensive examples
dart run example/lib/comprehensive_example.dart

# Usage guide
dart run example/lib/usage_guide.dart
```

## Schema Formats

The API supports two schema formats:

### Legacy Format

```json
{
  "User": {
    "id": "String",
    "name": "String",
    "email": "String"
  }
}
```

### Standard JSON Schema Format

```json
{
  "$defs": {
    "User": {
      "type": "object",
      "properties": {
        "id": { "type": "string" },
        "name": { "type": "string" },
        "email": { "type": "string" }
      }
    }
  }
}
```

The API automatically detects the format, but you can force a specific format using the `useLegacyFormat` parameter.

## Best Practices

1. **Always check the result**: Use `result.isSuccessful` before proceeding
2. **Handle specific exceptions**: Check exception types for appropriate error handling
3. **Validate inputs**: Ensure file paths and schemas are valid before calling the API
4. **Use appropriate methods**: Choose the method that best fits your use case
5. **Log errors**: Use the built-in logging for debugging

## Error Recovery

For robust applications, implement error recovery strategies:

```dart
Future<void> generateWithRetry(String schemaPath, String outputDir) async {
  final client = ApiGenClient();

  for (int attempt = 1; attempt <= 3; attempt++) {
    final result = await client.generateFromFile(schemaPath, outputDir);

    if (result.isSuccessful) {
      return;
    }

    if (attempt < 3) {
      print('Attempt $attempt failed, retrying...');
      await Future.delayed(Duration(seconds: attempt));
    } else {
      final failure = result as Failure<void>;
      throw Exception('Failed after 3 attempts: ${failure.exception}');
    }
  }
}
```
