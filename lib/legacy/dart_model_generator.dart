import 'dart:io';
import 'package:api_gen/legacy/case_helpers.dart';
import 'package:api_gen/src/exception/exception.dart';
import 'package:api_gen/src/logger/logger.dart';

class DartModelGenerator {
  final String outputDir;
  final Logger _logger;

  DartModelGenerator(this.outputDir) : _logger = Logger('DartModelGenerator');

  /// Generate a model from a schema
  ///
  /// [schema] - The schema as a [Map<String, dynamic>]
  ///

  void generate(Map<String, dynamic> schema) {
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

      // Generate models with individual error handling
      for (final entry in schema.entries) {
        try {
          _generateModel(entry.key, entry.value, schema);
        } catch (e) {
          if (e is ApiGenException) {
            rethrow;
          }
          throw CodeGenerationException(
            'Failed to generate legacy model: ${entry.key}',
            e,
          );
        }
      }

      _logger.info('Successfully generated ${schema.length} legacy models');
    } on ApiGenException catch (e, st) {
      _logger.error('ApiGenException: ${e.message}', e, st);
      rethrow;
    } catch (e, st) {
      final ex = CodeGenerationException(
        'Unknown error in legacy model generation',
        e,
      );
      _logger.error('Unknown error: $e', e, st);
      throw ex;
    }
  }

  /// Generates a model
  ///
  /// [className] - The name of the class
  /// [fields] - The fields of the model
  /// [schema] - The schema as a [Map<String, dynamic>]
  ///

  void _generateModel(
    String className,
    dynamic fields,
    Map<String, dynamic> schema,
  ) {
    try {
      final buffer = StringBuffer();
      final capClassName = capitalize(className);

      // Validate model name
      if (capClassName.isEmpty) {
        throw const CodeGenerationException('Model name cannot be empty');
      }

      // Track imports
      final imports = <String>{};

      // === Collect imports ===
      (fields as Map<String, dynamic>).forEach((name, def) {
        try {
          final type = _getType(def, schema);
          if (!_isPrimitive(type) && type != capClassName) {
            imports.add("import '${type.toLowerCase()}.dart';");
          }
        } catch (e) {
          throw CodeGenerationException('Failed to process field: $name', e);
        }
      });

      // Write imports at top
      for (var imp in imports) {
        buffer.writeln(imp);
      }
      if (imports.isNotEmpty) buffer.writeln();

      // === Class Definition ===
      buffer.writeln('class $capClassName {');

      // === Fields ===
      fields.forEach((name, def) {
        try {
          final type = _getType(def, schema);
          final required = _isRequired(def);
          buffer.writeln('  final $type${required ? "" : "?"} $name;');
        } catch (e) {
          throw CodeGenerationException('Failed to generate field: $name', e);
        }
      });

      buffer.writeln();
      // === Constructor ===
      buffer.writeln('  $capClassName({');
      fields.forEach((name, def) {
        try {
          final required = _isRequired(def);
          buffer.writeln('    ${required ? "required " : ""}this.$name,');
        } catch (e) {
          throw CodeGenerationException(
            'Failed to generate constructor parameter: $name',
            e,
          );
        }
      });
      buffer.writeln('  });\n');

      // === fromJson ===
      buffer.writeln(
        '  factory $capClassName.fromJson(Map<String, dynamic> json) {',
      );
      buffer.writeln('    return $capClassName(');
      fields.forEach((name, def) {
        try {
          final type = _getType(def, schema);
          final required = _isRequired(def);

          if (_isPrimitive(type)) {
            buffer.writeln(
              "      $name: json['$name'] as $type${required ? '' : '?'},",
            );
          } else {
            buffer.writeln(
              "      $name: json['$name'] != null ? $type.fromJson(json['$name']) : null,",
            );
          }
        } catch (e) {
          throw CodeGenerationException(
            'Failed to generate fromJson for field: $name',
            e,
          );
        }
      });
      buffer.writeln('    );');
      buffer.writeln('  }\n');

      // === toJson ===
      buffer.writeln('  Map<String, dynamic> toJson() {');
      buffer.writeln('    return {');
      fields.forEach((name, def) {
        try {
          final type = _getType(def, schema);
          if (_isPrimitive(type)) {
            buffer.writeln("      '$name': $name,");
          } else {
            buffer.writeln("      '$name': $name?.toJson(),");
          }
        } catch (e) {
          throw CodeGenerationException(
            'Failed to generate toJson for field: $name',
            e,
          );
        }
      });
      buffer.writeln('    };');
      buffer.writeln('  }');

      buffer.writeln('}');

      // === Save file ===
      _saveModelFile(className, buffer.toString());
    } catch (e) {
      if (e is ApiGenException) {
        rethrow;
      }
      throw CodeGenerationException(
        'Failed to generate legacy model: $className',
        e,
      );
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
      _logger.info('Generated legacy model file: $filePath');
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

  /// Extracts the type from a schema field
  ///
  /// [def] - The field definition
  /// [schema] - The schema as a [Map<String, dynamic>]
  ///
  /// Returns the type as a [String]

  String _getType(dynamic def, Map<String, dynamic> schema) {
    try {
      if (def == null) {
        throw const CodeGenerationException('Field definition cannot be null');
      }

      final rawType = def is String ? def : def['type'] as String;
      if (rawType.isEmpty) {
        throw const CodeGenerationException('Field type cannot be empty');
      }

      final norm = normalizeType(rawType);

      // If schema contains this type name, it's a nested object
      if (schema.containsKey(rawType.toLowerCase())) {
        return capitalize(rawType);
      }
      return norm;
    } catch (e) {
      if (e is ApiGenException) {
        rethrow;
      }
      throw CodeGenerationException(
        'Failed to extract type from field definition',
        e,
      );
    }
  }

  /// Check if a field is required
  ///
  /// [def] - The field definition
  ///
  /// Returns a [bool] indicating if the field is required

  bool _isRequired(dynamic def) {
    try {
      if (def == null) {
        throw const CodeGenerationException('Field definition cannot be null');
      }
      return def is String ? true : (def['required'] as bool? ?? true);
    } catch (e) {
      if (e is ApiGenException) {
        rethrow;
      }
      throw CodeGenerationException(
        'Failed to determine if field is required',
        e,
      );
    }
  }

  /// Check if a type is a primitive type
  ///
  /// [type] - The type to check
  ///
  /// Returns a [bool] indicating if the type is a primitive type
  ///

  bool _isPrimitive(String type) {
    if (type.isEmpty) {
      throw const CodeGenerationException('Type cannot be empty');
    }
    return ['String', 'int', 'double', 'bool', 'DateTime'].contains(type);
  }
}
