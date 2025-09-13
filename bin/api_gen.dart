import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:api_gen/api_gen.dart';
import 'package:api_gen/src/logger/logger.dart';

import 'package:api_gen/src/legacy/dart_model_generator.dart';

/// Entry point for the api_gen command-line tool.
///
/// This CLI tool generates Dart models from a JSON schema file. It supports both
/// standard JSON Schema and legacy formats. Use the `-s` option to specify the schema file
/// and the `-d` option to specify the output directory.
///
/// Example usage:
/// ```sh
/// dart run bin/api_gen.dart -s api.json -d lib/models
/// ```
void main(List<String> arguments) async {
  final logger = Logger('api_gen_cli');
  final parser = ArgParser()
    ..addOption(
      'schema',
      abbr: 's',
      help: 'Path to JSON schema',
      mandatory: true,
    )
    ..addOption('dir', abbr: 'd', help: 'Output directory');

  try {
    final args = parser.parse(arguments);

    final inputFile = args['schema'];
    final outputDir = args['dir'];

    if (inputFile == null || outputDir == null) {
      print('Usage: dart run api_gen -s api.json -d lib/models');
      exit(1);
    }

    final file = File(inputFile);
    if (!file.existsSync()) {
      print('❌ File not found: $inputFile');
      exit(2);
    }

    final jsonStr = await file.readAsString();
    final schema = jsonDecode(jsonStr) as Map<String, dynamic>;

    // Detect if schema is standard JSON Schema or legacy format
    bool isStandardJsonSchema(Map<String, dynamic> s) {
      return s.containsKey('\$defs') ||
          s.containsKey('definitions') ||
          (s['type'] == 'object' && s.containsKey('properties'));
    }

    if (isStandardJsonSchema(schema)) {
      final generator = ModelGenerator(outputDir);
      final result = generator.generate(schema);
      if (result.isSuccessful) {
        print('✅ Models generated in $outputDir (standard JSON Schema)');
      } else if (result.isFailure) {
        final failure = result as Failure<void>;
        logger.error('Model generation failed', failure.exception);
        print('❌ Model generation failed: ${failure.exception}');
        exit(2);
      }
    } else {
      final generator = DartModelGenerator(outputDir);
      try {
        generator.generate(schema);
        print('✅ Models generated in $outputDir (legacy format)');
      } on ApiGenException catch (e, st) {
        logger.error('Legacy model generation failed: ${e.message}', e, st);
        print('❌ Legacy model generation failed: ${e.message}');
        exit(2);
      } catch (e, st) {
        logger.error('Unknown error in legacy model generation', e, st);
        print('❌ Unknown error in legacy model generation: $e');
        exit(2);
      }
    }
  } on ApiGenException catch (e, st) {
    logger.error('ApiGenException: ${e.message}', e, st);
    print('❌ Error: ${e.message}');
    exit(2);
  } catch (e, st) {
    logger.error('Unknown error in CLI', e, st);
    print('❌ Unknown error: $e');
    exit(2);
  }
}
