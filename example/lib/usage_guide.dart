import 'dart:io';
import 'package:api_gen/api_gen.dart';

/// Simple usage guide for the ApiGenClient
void main() async {
  print('📚 ApiGen Usage Guide\n');

  // Create the client
  final client = ApiGenClient();

  // Method 1: Generate from file (recommended for most cases)
  print('Method 1: Generate from file');
  final result1 = await client.generateFromFile(
    'api.json',
    'lib/models/output_models',
  );
  handleResult(result1, 'File generation');

  // Method 2: Generate from schema Map (for programmatic use)
  print('\nMethod 2: Generate from schema Map');
  final schema = {
    'User': {'id': 'String', 'name': 'String', 'email': 'String'},
  };
  final result2 = await client.generateFromSchema(
    schema,
    'lib/models/output_models2',
  );
  handleResult(result2, 'Schema Map generation');

  // Method 3: Generate from JSON string
  print('\nMethod 3: Generate from JSON string');
  const jsonString = '{"Product": {"id": "String", "name": "String"}}';
  final result3 = await client.generateFromJsonString(
    jsonString,
    'lib/models/output_models3',
  );
  handleResult(result3, 'JSON string generation');

  print('\n🎉 Usage guide completed!');
}

void handleResult(Result<void> result, String operation) {
  if (result.isSuccessful) {
    print('   ✅ $operation successful');
  } else {
    final failure = result as Failure<void>;
    print('   ❌ $operation failed: ${failure.exception}');
    exit(1);
  }
}
