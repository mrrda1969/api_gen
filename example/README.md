# api_gen Example

This example demonstrates how to use the `api_gen` package to generate Dart model classes from a JSON schema, both via the command-line interface (CLI) and programmatically in Dart.

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

## 📁 Project Structure

```
example/
  api.json           # Your API schema
  lib/
    main.dart        # Dart usage example
    models/          # Generated models (output)
```

---

## 📝 Prepare Your Schema

Place your API schema in `example/api.json`. Example:

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

---

## 🚀 Generate Models via CLI

From the root of your project, run:

````sh
# Usage: api_gen --schema <input_schema> --dir <output_dir>
api_gen --schema api.json --dir lib/models

Options:

--schema / -s: Path to schema JSON file (required)

--dir / -d: Output directory for generated models (default: lib/models)

---

## 🧑‍💻 Generate Models Programmatically

You can also generate models in Dart code. See `example/lib/main.dart`:

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
````

Run this example:

```sh
cd example/lib
dart main.dart
```

---

## 📦 Output

After running either method, you will find generated Dart model files in the `lib/models` directory of your project.

---

## 📝 Notes

- Ensure your schema is valid JSON and follows the expected structure.
- The output directory will be created if it does not exist.
- For more advanced usage, see the main [package documentation](../README.md).
