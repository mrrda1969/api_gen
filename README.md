# api_gen

A simple Dart code generator for creating model classes (`fromJson` / `toJson`) from a JSON schema.  
Skip boilerplate and speed up API integration in your Dart and Flutter projects.

---

## ✨ Features

- Generate Dart model classes from a JSON schema
- Automatic `fromJson` and `toJson` methods
- Differentiates between **required** and **optional** fields
- Auto-capitalizes class names and normalizes Dart types
- Supports **nested models** with correct imports
- CLI and programmatic usage
- Output directory is created automatically

---

## 🚀 Getting Started

### 1. Add Dependency

Add `api_gen` to your `pubspec.yaml` (if using as a dependency):

```yaml
dependencies:
  api_gen: <latest_version>
```

Or activate globally to use as a CLI:

```sh
dart pub global activate api_gen
```

### 2. Usage

# Prepare Your Schema

Create a JSON schema file, e.g. api.json:

```json
{
  "user": {
    "id": "int",
    "name": "String",
    "email": { "type": "String", "required": false },
    "profile": {
      "type": "Profile",
      "required": true
    }
  },
  "profile": {
    "age": "int",
    "bio": { "type": "String", "required": false }
  }
}
```

# Generate Models via CLI

From your project root, run:

```sh
# Usage: api_gen --schema <input_schema> --dir <output_dir>
api_gen --schema api.json --dir lib/models
```

Options:

--schema / -s: Path to schema JSON file (required)

--dir / -d: Output directory for generated models (default: lib/models)

# Generate Models Programmatically

```dart
import 'dart:convert';
import 'dart:io';
import 'package:api_gen/api_gen.dart';

void main() async {
	final schemaFile = File('../api.json');
	final schema = jsonDecode(await schemaFile.readAsString()) as Map<String, dynamic>;
	final generator = DartModelGenerator('models');
	generator.generate(schema);
	print('✅ Models generated!');
}
```

---

## Example

See the [`example/`](example/) directory and its [README](example/README.md) for a complete working example, including project structure, schema, and both CLI and Dart API usage.

---

## Contributing

Contributions are welcome! Please open issues or submit pull requests.

---

## License

This project is licensed under the MIT License.
