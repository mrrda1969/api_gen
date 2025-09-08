# api_gen

A powerful Dart code generator for creating model classes (`fromJson` / `toJson`) from JSON schemas.  
Skip boilerplate and speed up API integration in your Dart and Flutter projects with robust exception handling and multiple usage patterns.

---

## ✨ Features

- 🚀 **Multiple Generation Methods**: CLI, programmatic API, and direct generator usage
- 🔧 **Robust Exception Handling**: Comprehensive error handling with specific exception types
- 📝 **Auto-Generated Code**: Automatic `fromJson` and `toJson` methods
- ✅ **Type Safety**: Differentiates between **required** and **optional** fields
- 🎯 **Smart Type Mapping**: Auto-capitalizes class names and normalizes Dart types
- 🔗 **Nested Models**: Supports nested models with correct imports
- 📁 **Auto Directory Creation**: Output directory is created automatically
- 🛡️ **Input Validation**: Validates schemas, file paths, and JSON format
- 📊 **Multiple Schema Formats**: Supports both legacy and standard JSON Schema formats

---

## 🚀 Getting Started

### 1. Installation

Add `api_gen` to your `pubspec.yaml`:

```yaml
dependencies:
  api_gen: ^0.0.4
```

Or activate globally to use as a CLI:

```sh
dart pub global activate api_gen
```

### 2. Usage Options

## 🖥️ CLI Usage (Recommended for Quick Generation)

```sh
# Basic usage
api_gen --schema api.json --dir lib/models

# Short form
api_gen -s api.json -d lib/models
```

**Options:**

- `--schema` / `-s`: Path to schema JSON file (required)
- `--dir` / `-d`: Output directory for generated models (default: lib/models)

## 🧑‍💻 Programmatic Usage (Recommended for Integration)

### Using the High-Level ApiGenClient

```dart
import 'package:api_gen/api_gen.dart';

void main() async {
  final client = ApiGenClient();

  // Generate from file
  final result = await client.generateFromFile('api.json', 'lib/models');

  if (result.isSuccessful) {
    print('✅ Models generated successfully!');
  } else {
    final failure = result as Failure<void>;
    print('❌ Error: ${failure.exception}');
  }
}
```

### Available Methods

```dart
// 1. Generate from file
await client.generateFromFile('schema.json', 'lib/models');

// 2. Generate from schema Map
final schema = {'User': {'id': 'String', 'name': 'String'}};
await client.generateFromSchema(schema, 'lib/models');

// 3. Generate from JSON string
const jsonString = '{"Product": {"id": "String"}}';
await client.generateFromJsonString(jsonString, 'lib/models');
```

## 📝 Schema Formats

### Legacy Format (Simple)

```json
{
  "user": {
    "id": "int",
    "name": "String",
    "email": { "type": "String", "required": false },
    "profile": { "type": "Profile", "required": true }
  },
  "profile": {
    "age": "int",
    "bio": { "type": "String", "required": false }
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
      },
      "required": ["id", "name"]
    }
  }
}
```

---

## 🛡️ Exception Handling

The package provides comprehensive exception handling with specific exception types:

```dart
final result = await client.generateFromFile('schema.json', 'models');

if (result.isFailure) {
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

**Exception Types:**

- `FileOperationException`: File I/O errors (file not found, permission denied, etc.)
- `SchemaValidationException`: Invalid or empty schemas
- `CodeGenerationException`: Model generation errors
- `JsonParsingException`: JSON parsing errors

---

## 📚 Examples

See the [`example/`](example/) directory for comprehensive examples:

- **`main.dart`** - Basic usage with ApiGenClient
- **`comprehensive_example.dart`** - All usage patterns and error handling
- **`usage_guide.dart`** - Step-by-step guide
- **`API_USAGE.md`** - Detailed API documentation

### Quick Example

```dart
import 'package:api_gen/api_gen.dart';

void main() async {
  final client = ApiGenClient();

  // Generate models with proper error handling
  final result = await client.generateFromFile('api.json', 'lib/models');

  if (result.isSuccessful) {
    print('✅ Models generated successfully!');
  } else {
    final failure = result as Failure<void>;
    print('❌ Error: ${failure.exception}');
  }
}
```

---

## 🔧 Advanced Usage

### Direct Generator Usage

For more control, you can use the generators directly:

```dart
import 'package:api_gen/api_gen.dart';

// For legacy format
final legacyGenerator = DartModelGenerator('lib/models');
legacyGenerator.generate(schema);

// For standard JSON Schema format
final generator = ModelGenerator('lib/models');
final result = generator.generate(schema);
```

### Custom Error Handling

```dart
Future<void> generateWithRetry(String schemaPath, String outputDir) async {
  final client = ApiGenClient();

  for (int attempt = 1; attempt <= 3; attempt++) {
    final result = await client.generateFromFile(schemaPath, outputDir);

    if (result.isSuccessful) return;

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

---

## 📋 Changelog

### v0.0.4

- ✨ Added `ApiGenClient` for high-level programmatic usage
- 🛡️ Comprehensive exception handling with specific exception types
- 🔧 Enhanced input validation and error recovery
- 📚 Multiple usage examples and comprehensive documentation
- 🚀 Support for both legacy and standard JSON Schema formats
- 📝 Improved CLI error messages and logging

### v0.0.3

- Support for nested models
- CLI global executable support

---

## 🤝 Contributing

Contributions are welcome! Please open issues or submit pull requests.

---

## 📄 License

This project is licensed under the MIT License.
