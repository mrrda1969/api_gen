import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:api_gen/api_gen.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'schema',
      abbr: 's',
      help: 'Path to JSON schema',
      mandatory: true,
    )
    ..addOption('dir', abbr: 'd', help: 'Output directory');

  final args = parser.parse(arguments);

  final inputFile = args['schema'];
  final outputDir = args['dir'];

  if (inputFile == null || outputDir == null) {
    print('Usage: dart run api_gen -s api.json -d lib/models');
    exit(1);
  }

  final jsonStr = await File(inputFile).readAsString();
  final schema = jsonDecode(jsonStr) as Map<String, dynamic>;

  // Detect if schema is standard JSON Schema or legacy format
  bool isStandardJsonSchema(Map<String, dynamic> s) {
    return s.containsKey('\$defs') ||
        s.containsKey('definitions') ||
        (s['type'] == 'object' && s.containsKey('properties'));
  }

  if (isStandardJsonSchema(schema)) {
    final generator = ModelGenerator(outputDir);
    generator.generate(schema);
    print('✅ Models generated in $outputDir (standard JSON Schema)');
  } else {
    final generator = DartModelGenerator(outputDir);
    generator.generate(schema);
    print('✅ Models generated in $outputDir (legacy format)');
  }
}
