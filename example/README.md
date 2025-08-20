# Example Usage for `api_gen`

This example demonstrates how to use the `api_gen` package to generate Dart models from an OpenAPI-style JSON schema, both via the command-line interface (CLI) and programmatically in Dart.

---

## 1. Project Structure

```
example/
  api.json           # Your API schema
  lib/
    main.dart        # Dart usage example
  models/            # Generated models (output)
```

---

## 2. Prepare Your API Schema

Place your API schema in `example/api.json`. Example:

```json
{
  "user": {
    "id": "int",
    "name": "String",
    "email": { "type": "String", "required": false }
  }
}
```

---

## 3. Using the CLI

You can generate Dart models from your schema using the CLI:

```sh
# From the root of your project
# Usage: dart api_gen -i <input_schema> -o <output_dir>
dart run api_gen -i api.json -o lib/models
```

This will generate Dart model files in the `lib/models` directory of your project.

---

## 4. Using the Dart API

You can also generate models programmatically in Dart. See `example/lib/main.dart`:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:api_gen/api_gen.dart';

void main() async {
  // Load schema from api.json
  final schemaFile = File('../api.json');
  final schema =
      jsonDecode(await schemaFile.readAsString()) as Map<String, dynamic>;

  // Generate models into models/
  final generator = DartModelGenerator('models');
  generator.generate(schema);

  print('✅ Example models generated in models');
}
```

Run this example:

```sh
cd example/lib
dart main.dart
```

---

## 5. Output

After running either method, you will find generated Dart model files in the `lib/models` directory of your project.

---

## 6. Notes

- Ensure your schema is valid JSON and follows the expected structure.
- The output directory will be created if it does not exist.
- For more advanced usage, see the main package documentation.
