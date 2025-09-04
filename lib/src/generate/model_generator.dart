import 'dart:io';
import 'package:api_gen/src/parser/schema_parser.dart';
import 'package:api_gen/src/exception/exception.dart';
import 'package:api_gen/src/logger/logger.dart';
import 'package:api_gen/src/result/result.dart';

class ModelGenerator {
  final String outputDir;
  final Logger _logger;

  ModelGenerator(this.outputDir) : _logger = Logger('ModelGenerator');

  Result<void> generate(Map<String, dynamic> schema) {
    try {
      final dir = Directory(outputDir);
      if (!dir.existsSync()) {
        try {
          dir.createSync(recursive: true);
        } catch (e) {
          throw FileOperationException(
            'Could not create output directory: $outputDir',
            e,
          );
        }
      }

      // Parse the schema using the standard parser
      final models = parseSchema(schema);

      for (final entry in models.entries) {
        final model = entry.value;
        final buffer = StringBuffer();
        final className = model.name;

        // Track imports for nested models
        final imports = <String>{};
        for (final prop in model.properties) {
          final type = _extractBaseType(prop.dartType);
          if (!_isPrimitive(type) && type != className) {
            imports.add("import '${type.toLowerCase()}.dart';");
          }
        }
        for (var imp in imports) {
          buffer.writeln(imp);
        }
        if (imports.isNotEmpty) buffer.writeln();

        // === Class Definition ===
        buffer.writeln('class $className {');

        // === Fields ===
        for (final prop in model.properties) {
          buffer.writeln('  final ${prop.dartType} ${prop.name};');
        }

        buffer.writeln();
        // === Constructor ===
        buffer.writeln('  $className({');
        for (final prop in model.properties) {
          buffer.writeln(
            '    ${prop.isRequired ? "required " : ""}this.${prop.name},',
          );
        }
        buffer.writeln('  });\n');

        // === fromJson ===
        buffer.writeln(
          '  factory $className.fromJson(Map<String, dynamic> json) {',
        );
        buffer.writeln('    return $className(');
        for (final prop in model.properties) {
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
        }
        buffer.writeln('    );');
        buffer.writeln('  }\n');

        // === toJson ===
        buffer.writeln('  Map<String, dynamic> toJson() {');
        buffer.writeln('    return {');
        for (final prop in model.properties) {
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
        }
        buffer.writeln('    };');
        buffer.writeln('  }');

        buffer.writeln('}');

        // === Save file ===
        final filePath = '$outputDir/${className.toLowerCase()}.dart';
        final file = File(filePath);
        try {
          file.writeAsStringSync(buffer.toString());
        } catch (e) {
          throw FileOperationException('Could not write to file: $filePath', e);
        }
      }
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

  bool _isPrimitive(String type) {
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

  String _extractBaseType(String dartType) {
    // Handles nullable and generic types
    var t = dartType.replaceAll('?', '');
    if (t.startsWith('List<') && t.endsWith('>')) {
      t = t.substring(5, t.length - 1);
    }
    return t;
  }
}
