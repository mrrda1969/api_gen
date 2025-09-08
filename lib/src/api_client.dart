import 'dart:convert';
import 'dart:io';
import 'package:api_gen/src/exception/exception.dart';
import 'package:api_gen/src/generate/model_generator.dart';
import 'package:api_gen/legacy/dart_model_generator.dart';
import 'package:api_gen/src/logger/logger.dart';
import 'package:api_gen/src/result/result.dart';

/// A high-level API client for programmatic use of api_gen
class ApiGenClient {
  final Logger _logger;

  ApiGenClient() : _logger = Logger('ApiGenClient');

  /// Generate models from a JSON schema file
  ///
  /// [schemaPath] - Path to the JSON schema file
  /// [outputDir] - Directory where generated models will be saved
  /// [useLegacyFormat] - Whether to use the legacy format (default: auto-detect)
  ///
  /// Returns a [Result] indicating success or failure
  Future<Result<void>> generateFromFile(
    String schemaPath,
    String outputDir, {
    bool? useLegacyFormat,
  }) async {
    try {
      /// Check if schema path is empty
      if (schemaPath.isEmpty) {
        throw const FileOperationException('Schema path cannot be empty');
      }

      /// Check if output directory is empty
      if (outputDir.isEmpty) {
        throw const FileOperationException('Output directory cannot be empty');
      }

      /// Check if schema file exists
      final schemaFile = File(schemaPath);
      if (!schemaFile.existsSync()) {
        throw FileOperationException('Schema file not found: $schemaPath');
      }

      /// Read and parse schema
      final schema = await _readSchemaFile(schemaFile);

      /// Generate models
      return await generateFromSchema(
        schema,
        outputDir,
        useLegacyFormat: useLegacyFormat,
      );
    } on ApiGenException catch (e, st) {
      _logger.error('ApiGenException in generateFromFile: ${e.message}', e, st);
      return Result.failure(e);
    } catch (e, st) {
      final ex = CodeGenerationException(
        'Unknown error in generateFromFile',
        e,
      );
      _logger.error('Unknown error in generateFromFile: $e', e, st);
      return Result.failure(ex);
    }
  }

  /// Generate models from a schema Map
  ///
  /// [schema] - The schema as a [Map<String, dynamic>]
  /// [outputDir] - Directory where generated models will be saved
  /// [useLegacyFormat] - Whether to use the legacy format (default: auto-detect)
  ///
  /// Returns a [Result] indicating success or failure
  Future<Result<void>> generateFromSchema(
    Map<String, dynamic> schema,
    String outputDir, {
    bool? useLegacyFormat,
  }) async {
    try {
      /// Check if schema is empty
      if (schema.isEmpty) {
        throw const SchemaValidationException('Schema cannot be empty');
      }

      /// Check if output directory is empty
      if (outputDir.isEmpty) {
        throw const FileOperationException('Output directory cannot be empty');
      }

      /// Auto-detect format if not specified
      final isLegacy = useLegacyFormat ?? _isLegacyFormat(schema);

      if (isLegacy) {
        _logger.info('Using legacy format for schema');
        final generator = DartModelGenerator(outputDir);
        generator.generate(schema);
      } else {
        _logger.info('Using standard JSON Schema format');
        final generator = ModelGenerator(outputDir);
        final result = generator.generate(schema);
        if (result.isFailure) {
          return result;
        }
      }

      _logger.info('Successfully generated models in $outputDir');
      return const Result.success(null);
    } on ApiGenException catch (e, st) {
      _logger.error(
        'ApiGenException in generateFromSchema: ${e.message}',
        e,
        st,
      );
      return Result.failure(e);
    } catch (e, st) {
      final ex = CodeGenerationException(
        'Unknown error in generateFromSchema',
        e,
      );
      _logger.error('Unknown error in generateFromSchema: $e', e, st);
      return Result.failure(ex);
    }
  }

  /// Generate models from a JSON string
  ///
  /// [jsonString] - The schema as a JSON string
  /// [outputDir] - Directory where generated models will be saved
  /// [useLegacyFormat] - Whether to use the legacy format (default: auto-detect)
  ///
  /// Returns a [Result] indicating success or failure
  Future<Result<void>> generateFromJsonString(
    String jsonString,
    String outputDir, {
    bool? useLegacyFormat,
  }) async {
    try {
      /// Check if JSON string is empty
      if (jsonString.isEmpty) {
        throw const SchemaValidationException('JSON string cannot be empty');
      }

      final schema = jsonDecode(jsonString) as Map<String, dynamic>;
      return await generateFromSchema(
        schema,
        outputDir,
        useLegacyFormat: useLegacyFormat,
      );
    } on FormatException catch (e, st) {
      final ex = JsonParsingException('Invalid JSON format: ${e.message}', e);
      _logger.error('JSON parsing error: ${e.message}', e, st);
      return Result.failure(ex);
    } on ApiGenException catch (e, st) {
      _logger.error(
        'ApiGenException in generateFromJsonString: ${e.message}',
        e,
        st,
      );
      return Result.failure(e);
    } catch (e, st) {
      final ex = CodeGenerationException(
        'Unknown error in generateFromJsonString',
        e,
      );
      _logger.error('Unknown error in generateFromJsonString: $e', e, st);
      return Result.failure(ex);
    }
  }

  /// Read and parse a schema file with proper error handling
  Future<Map<String, dynamic>> _readSchemaFile(File schemaFile) async {
    try {
      final jsonString = await schemaFile.readAsString();
      if (jsonString.isEmpty) {
        throw const SchemaValidationException('Schema file is empty');
      }

      final schema = jsonDecode(jsonString) as Map<String, dynamic>;
      return schema;
    } on FormatException catch (e) {
      throw JsonParsingException(
        'Invalid JSON in schema file: ${e.message}',
        e,
      );
    } catch (e) {
      if (e is ApiGenException) {
        rethrow;
      }
      throw FileOperationException(
        'Failed to read schema file: ${schemaFile.path}',
        e,
      );
    }
  }

  /// Detect if schema uses legacy format
  bool _isLegacyFormat(Map<String, dynamic> schema) {
    /// Legacy format detection logic
    return !schema.containsKey('\$defs') &&
        !schema.containsKey('definitions') &&
        !(schema['type'] == 'object' && schema.containsKey('properties'));
  }
}
