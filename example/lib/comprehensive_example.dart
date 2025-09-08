import 'package:api_gen/api_gen.dart';

/// Comprehensive example showing different ways to use the ApiGenClient
void main() async {
  final client = ApiGenClient();

  print('🚀 ApiGen Comprehensive Example\n');

  // Example 1: Generate from file
  await example1GenerateFromFile(client);

  // Example 2: Generate from schema Map
  await example2GenerateFromSchema(client);

  // Example 3: Generate from JSON string
  await example3GenerateFromJsonString(client);

  // Example 4: Error handling demonstration
  await example4ErrorHandling(client);

  print('\n✅ All examples completed!');
}

/// Example 1: Generate models from a file
Future<void> example1GenerateFromFile(ApiGenClient client) async {
  print('📁 Example 1: Generate from file');

  final result = await client.generateFromFile(
    'api.json',
    'models/models_from_file',
  );

  if (result.isSuccessful) {
    print('   ✅ Successfully generated models from file');
  } else {
    final failure = result as Failure<void>;
    print('   ❌ Failed: ${failure.exception}');
  }
  print('');
}

/// Example 2: Generate models from a schema Map
Future<void> example2GenerateFromSchema(ApiGenClient client) async {
  print('📋 Example 2: Generate from schema Map');

  final schema = {
    'Product': {
      'id': 'String',
      'name': 'String',
      'price': 'double',
      'inStock': 'bool',
    },
    'Order': {
      'id': 'String',
      'productId': 'String',
      'quantity': 'int',
      'total': 'double',
      'createdAt': 'DateTime',
    },
  };

  final result = await client.generateFromSchema(
    schema,
    'models/models_from_map',
  );

  if (result.isSuccessful) {
    print('   ✅ Successfully generated models from schema Map');
  } else {
    final failure = result as Failure<void>;
    print('   ❌ Failed: ${failure.exception}');
  }
  print('');
}

/// Example 3: Generate models from JSON string
Future<void> example3GenerateFromJsonString(ApiGenClient client) async {
  print('📄 Example 3: Generate from JSON string');

  const jsonString = '''
  {
    "Category": {
      "id": "String",
      "name": "String",
      "description": "String"
    },
    "Tag": {
      "id": "String",
      "name": "String",
      "color": "String"
    }
  }
  ''';

  final result = await client.generateFromJsonString(
    jsonString,
    'models/models_from_json',
  );

  if (result.isSuccessful) {
    print('   ✅ Successfully generated models from JSON string');
  } else {
    final failure = result as Failure<void>;
    print('   ❌ Failed: ${failure.exception}');
  }
  print('');
}

/// Example 4: Demonstrate error handling
Future<void> example4ErrorHandling(ApiGenClient client) async {
  print('⚠️  Example 4: Error handling demonstration');

  // Try to generate from a non-existent file
  final result1 = await client.generateFromFile(
    'non_existent.json',
    'models/models_error',
  );
  if (result1.isFailure) {
    final failure = result1 as Failure<void>;
    print('   ❌ Expected error for non-existent file: ${failure.exception}');
  }

  // Try to generate from empty schema
  final result2 = await client.generateFromSchema({}, 'models/models_empty');
  if (result2.isFailure) {
    final failure = result2 as Failure<void>;
    print('   ❌ Expected error for empty schema: ${failure.exception}');
  }

  // Try to generate from invalid JSON
  final result3 = await client.generateFromJsonString(
    'invalid json',
    'models/models_invalid',
  );
  if (result3.isFailure) {
    final failure = result3 as Failure<void>;
    print('   ❌ Expected error for invalid JSON: ${failure.exception}');
  }

  print('   ✅ Error handling working correctly');
  print('');
}
