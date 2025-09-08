import 'dart:io';
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
    exit(1);
  }
}
