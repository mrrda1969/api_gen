import 'dart:io';
import 'package:api_gen/src/parser/schema_parser.dart';
import 'package:api_gen/src/exception/exception.dart';
import 'package:api_gen/src/logger/logger.dart';
import 'package:api_gen/src/result/result.dart';

class ModelGenerator {
  final String outputDir;
  final Logger _logger;

  ModelGenerator(this.outputDir) : _logger = Logger('ModelGenerator');

  /// Generates a model from a schema
  ///
  /// [schema] - The schema as a [Map<String, dynamic>]
  ///
  /// Returns a [Result] indicating success or failure
  ///
  Result<void> generate(Map<String, dynamic> schema) {
    try {
      // Validate input schema
      if (schema.isEmpty) {
        throw const SchemaValidationException('Schema cannot be empty');
      }

      // Create output directory with proper error handling
      final dir = Directory(outputDir);
      if (!dir.existsSync()) {
        try {
          dir.createSync(recursive: true);
          _logger.info('Created output directory: $outputDir');
        } catch (e) {
          throw FileOperationException(
            'Could not create output directory: $outputDir',
            e,
          );
        }
      }

      // Parse the schema with error handling
      final models = _parseSchemaWithErrorHandling(schema);

      // Generate models with individual error handling
      for (final entry in models.entries) {
        try {
          _generateModel(entry.key, entry.value);
        } catch (e) {
          if (e is ApiGenException) {
            rethrow;
          }
          throw CodeGenerationException(
            'Failed to generate model: ${entry.key}',
            e,
          );
        }
      }

      _logger.info('Successfully generated ${models.length} models');
      return const Result.success(null);
    } on ApiGenException catch (e, st) {
      _logger.error('ApiGenException: ${e.message}', e, st);
      return Result.failure(e);
    } catch (e, st) {
      final ex = CodeGenerationException(
        'Unknown error in model generation',
        e,
      );
      _logger.error('Unknown error: $e', e, st);
      return Result.failure(ex);
    }
  }

  /// Parses a schema with error handling
  ///
  /// [schema] - The schema as a [Map<String, dynamic>]
  ///
  /// Returns the parsed schema as a [Map<String, dynamic>]

  Map<String, dynamic> _parseSchemaWithErrorHandling(
    Map<String, dynamic> schema,
  ) {
    try {
      return parseSchema(schema);
    } catch (e) {
      if (e is ApiGenException) {
        rethrow;
      }
      throw SchemaValidationException(
        'Failed to parse schema: ${e.toString()}',
        e,
      );
    }
  }

  /// Generates a model
  ///
  /// [modelName] - The name of the model
  /// [model] - The model as a [dynamic]

  void _generateModel(String modelName, dynamic model) {
    try {
      final buffer = StringBuffer();
      final className = model.name;

      // Validate model name
      if (className == null || className.isEmpty) {
        throw const CodeGenerationException(
          'Model name cannot be null or empty',
        );
      }

      // Track imports for nested models
      final imports = <String>{};
      for (final prop in model.properties) {
        try {
          final type = _extractBaseType(prop.dartType);
          if (!_isPrimitive(type) && type != className) {
            imports.add("import '${type.toLowerCase()}.dart';");
          }
        } catch (e) {
          throw CodeGenerationException(
            'Failed to process property: ${prop.name}',
            e,
          );
        }
      }

      // Write imports
      for (var imp in imports) {
        buffer.writeln(imp);
      }
      if (imports.isNotEmpty) buffer.writeln();

      // === Class Definition ===
      buffer.writeln('class $className {');

      // === Fields ===
      for (final prop in model.properties) {
        try {
          buffer.writeln('  final ${prop.dartType} ${prop.name};');
        } catch (e) {
          throw CodeGenerationException(
            'Failed to generate field for property: ${prop.name}',
            e,
          );
        }
      }

      buffer.writeln();
      // === Constructor ===
      buffer.writeln('  $className({');
      for (final prop in model.properties) {
        try {
          buffer.writeln(
            '    ${prop.isRequired ? "required " : ""}this.${prop.name},',
          );
        } catch (e) {
          throw CodeGenerationException(
            'Failed to generate constructor parameter for property: ${prop.name}',
            e,
          );
        }
      }
      buffer.writeln('  });\n');

      // === fromJson ===
      buffer.writeln(
        '  factory $className.fromJson(Map<String, dynamic> json) {',
      );
      buffer.writeln('    return $className(');
      for (final prop in model.properties) {
        try {
          final type = _extractBaseType(prop.dartType);
          if (_isPrimitive(type)) {
            buffer.writeln(
              "      ${prop.name}: json['${prop.name}'] as $type${prop.isNullable ? '?' : ''},",
            );
          } else if (prop.dartType.startsWith('List<')) {
            // Handle list of objects or primitives
            final innerType = prop.dartType.substring(
              5,
              prop.dartType.length - 1,
            );
            if (_isPrimitive(innerType)) {
              buffer.writeln(
                "      ${prop.name}: (json['${prop.name}'] as List?)?.cast<$innerType>(),",
              );
            } else {
              buffer.writeln(
                "      ${prop.name}: (json['${prop.name}'] as List?)?.map((e) => $innerType.fromJson(e)).toList(),",
              );
            }
          } else {
            buffer.writeln(
              "      ${prop.name}: json['${prop.name}'] != null ? $type.fromJson(json['${prop.name}']) : null,",
            );
          }
        } catch (e) {
          throw CodeGenerationException(
            'Failed to generate fromJson for property: ${prop.name}',
            e,
          );
        }
      }
      buffer.writeln('    );');
      buffer.writeln('  }\n');

      // === toJson ===
      buffer.writeln('  Map<String, dynamic> toJson() {');
      buffer.writeln('    return {');
      for (final prop in model.properties) {
        try {
          final type = _extractBaseType(prop.dartType);
          if (_isPrimitive(type)) {
            buffer.writeln("      '${prop.name}': ${prop.name},");
          } else if (prop.dartType.startsWith('List<')) {
            final innerType = prop.dartType.substring(
              5,
              prop.dartType.length - 1,
            );
            if (_isPrimitive(innerType)) {
              buffer.writeln("      '${prop.name}': ${prop.name},");
            } else {
              buffer.writeln(
                "      '${prop.name}': ${prop.name}?.map((e) => e.toJson()).toList(),",
              );
            }
          } else {
            buffer.writeln("      '${prop.name}': ${prop.name}?.toJson(),");
          }
        } catch (e) {
          throw CodeGenerationException(
            'Failed to generate toJson for property: ${prop.name}',
            e,
          );
        }
      }
      buffer.writeln('    };');
      buffer.writeln('  }');

      buffer.writeln('}');

      // === Save file ===
      _saveModelFile(className, buffer.toString());
    } catch (e) {
      if (e is ApiGenException) {
        rethrow;
      }
      throw CodeGenerationException('Failed to generate model: $modelName', e);
    }
  }

  /// Saves a model file
  ///
  /// [className] - The name of the class
  /// [content] - The content of the file

  void _saveModelFile(String className, String content) {
    try {
      final filePath = '$outputDir/${className.toLowerCase()}.dart';
      final file = File(filePath);

      // Validate file path
      if (filePath.contains('..') || filePath.contains('//')) {
        throw const FileOperationException('Invalid file path detected');
      }

      file.writeAsStringSync(content);
      _logger.info('Generated model file: $filePath');
    } catch (e) {
      if (e is ApiGenException) {
        rethrow;
      }
      throw FileOperationException(
        'Could not write to file: $outputDir/${className.toLowerCase()}.dart',
        e,
      );
    }
  }

  /// Checks if a type is a primitive type
  ///
  /// [type] - The type to check
  ///
  /// Returns a [bool] indicating if the type is a primitive type

  bool _isPrimitive(String type) {
    if (type.isEmpty) {
      throw const CodeGenerationException('Type cannot be empty');
    }

    return [
      'String',
      'int',
      'double',
      'bool',
      'DateTime',
      'dynamic',
      'num',
    ].contains(type);
  }

  /// Extracts the base type from a Dart type
  ///
  /// [dartType] - The Dart type to extract the base type from
  ///
  /// Returns the base type as a [String]

  String _extractBaseType(String dartType) {
    if (dartType.isEmpty) {
      throw const CodeGenerationException('Dart type cannot be empty');
    }

    try {
      // Handles nullable and generic types
      var t = dartType.replaceAll('?', '');
      if (t.startsWith('List<') && t.endsWith('>')) {
        t = t.substring(5, t.length - 1);
      }
      return t;
    } catch (e) {
      throw CodeGenerationException(
        'Failed to extract base type from: $dartType',
        e,
      );
    }
  }
}
