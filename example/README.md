# api_gen Example

This example demonstrates how to use the `api_gen` package to generate Dart model classes from a JSON schema using the new `ApiGenClient` with comprehensive exception handling.

---

## ✨ Features Demonstrated

- 🚀 **High-Level API**: Using `ApiGenClient` for easy integration
- 🛡️ **Exception Handling**: Comprehensive error handling with specific exception types
- 📝 **Multiple Usage Patterns**: File, schema Map, and JSON string generation
- 🔧 **Input Validation**: Automatic validation of schemas and file paths
- 📊 **Schema Format Support**: Both legacy and standard JSON Schema formats
- 🎯 **Error Recovery**: Proper error handling and user feedback

---

## 📁 Project Structure

```
example/
  api.json                    # Your API schema (legacy format)
  API_USAGE.md               # Detailed API documentation
  lib/
    main.dart                # Basic usage example
    comprehensive_example.dart # All usage patterns
    usage_guide.dart         # Step-by-step guide
    models/                  # Generated models (output)
      models_from_file/      # Generated from file
      models_from_map/       # Generated from schema Map
      models_from_json/      # Generated from JSON string
```

---

## 📝 Schema Format

The example uses a legacy format schema in `api.json`:

```json
{
  "user": {
    "id": {
      "type": "int",
      "required": true
    },
    "name": {
      "type": "string",
      "required": true
    },
    "email": {
      "type": "string",
      "required": false
    },
    "profile": {
      "type": "profile",
      "required": false
    }
  },
  "profile": {
    "id": {
      "type": "int",
      "required": true
    },
    "bio": {
      "type": "string",
      "required": false
    },
    "age": {
      "type": "int",
      "required": false
    }
  }
}
```

---

## 🚀 Usage Examples

### 1. Basic Usage (`main.dart`)

```dart
import 'package:api_gen/api_gen.dart';

void main() async {
  final client = ApiGenClient();

  // Generate models from api.json file
  final result = await client.generateFromFile('api.json', 'models');

  if (result.isSuccessful) {
    print('✅ Models generated successfully!');
  } else {
    final failure = result as Failure<void>;
    print('❌ Error: ${failure.exception}');
  }
}
```

### 2. Comprehensive Examples (`comprehensive_example.dart`)

Demonstrates all usage patterns:

- Generate from file
- Generate from schema Map
- Generate from JSON string
- Error handling scenarios

### 3. Usage Guide (`usage_guide.dart`)

Step-by-step guide showing different methods and error handling.

---

## 🖥️ CLI Usage

You can also use the CLI from the example directory:

```sh
# From the example directory
api_gen --schema api.json --dir lib/models

# Or from project root
api_gen --schema example/api.json --dir example/lib/models
```

---

## 🛡️ Exception Handling

The examples demonstrate proper exception handling:

```dart
final result = await client.generateFromFile('api.json', 'models');

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

---

## 🏃‍♂️ Running the Examples

```sh
# Basic example
dart run lib/main.dart

# Comprehensive examples
dart run lib/comprehensive_example.dart

# Usage guide
dart run lib/usage_guide.dart
```

---

## 📦 Generated Output

After running the examples, you'll find generated Dart model files in the `lib/models/` directory:

- `user.dart` - User model with nested Profile support
- `profile.dart` - Profile model
- Various subdirectories for different generation methods

---

## 📚 Additional Documentation

- **`API_USAGE.md`** - Comprehensive API documentation
- **Main README** - Complete package documentation
- **Code Examples** - Multiple working examples in the `lib/` directory

---

## 🔧 Advanced Usage

The examples also show advanced patterns like:

- Custom error handling
- Retry mechanisms
- Multiple schema formats
- Programmatic schema generation

For more details, see the individual example files and the main package documentation.
