import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:api_gen/generators/dart_model_generator.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('input', abbr: 'i', help: 'Path to JSON schema')
    ..addOption('output', abbr: 'o', help: 'Output folder');

  final args = parser.parse(arguments);

  final inputFile = args['input'];
  final outputDir = args['output'];

  if (inputFile == null || outputDir == null) {
    print('Usage: dart run api_gen -i api.json -o lib/models');
    exit(1);
  }

  final jsonStr = await File(inputFile).readAsString();
  final schema = jsonDecode(jsonStr) as Map<String, dynamic>;

  final generator = DartModelGenerator(outputDir);
  generator.generate(schema);

  print('✅ Models generated in $outputDir');
}
