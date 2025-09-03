import 'dart:io';

import 'package:api_gen/legacy/case_helpers.dart';

class DartModelGenerator {
  final String outputDir;

  DartModelGenerator(this.outputDir);

  void generate(Map<String, dynamic> schema) {
    final dir = Directory(outputDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    schema.forEach((className, fields) {
      final buffer = StringBuffer();
      final capClassName = capitalize(className);

      // Track imports
      final imports = <String>{};

      // === Collect imports ===
      (fields as Map<String, dynamic>).forEach((name, def) {
        final type = _getType(def, schema);
        if (!_isPrimitive(type) && type != capClassName) {
          imports.add("import '${type.toLowerCase()}.dart';");
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
        final type = _getType(def, schema);
        final required = _isRequired(def);
        buffer.writeln('  final $type${required ? "" : "?"} $name;');
      });

      buffer.writeln();
      // === Constructor ===
      buffer.writeln('  $capClassName({');
      fields.forEach((name, def) {
        final required = _isRequired(def);
        buffer.writeln('    ${required ? "required " : ""}this.$name,');
      });
      buffer.writeln('  });\n');

      // === fromJson ===
      buffer.writeln(
        '  factory $capClassName.fromJson(Map<String, dynamic> json) {',
      );
      buffer.writeln('    return $capClassName(');
      fields.forEach((name, def) {
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
      });
      buffer.writeln('    );');
      buffer.writeln('  }\n');

      // === toJson ===
      buffer.writeln('  Map<String, dynamic> toJson() {');
      buffer.writeln('    return {');
      fields.forEach((name, def) {
        final type = _getType(def, schema);
        if (_isPrimitive(type)) {
          buffer.writeln("      '$name': $name,");
        } else {
          buffer.writeln("      '$name': $name?.toJson(),");
        }
      });
      buffer.writeln('    };');
      buffer.writeln('  }');

      buffer.writeln('}');

      // === Save file ===
      final file = File('$outputDir/${className.toLowerCase()}.dart');
      file.writeAsStringSync(buffer.toString());
    });
  }

  /// Extract type from schema field
  String _getType(dynamic def, Map<String, dynamic> schema) {
    final rawType = def is String ? def : def['type'] as String;
    final norm = normalizeType(rawType);

    // If schema contains this type name, it’s a nested object
    if (schema.containsKey(rawType.toLowerCase())) {
      return capitalize(rawType);
    }
    return norm;
  }

  bool _isRequired(dynamic def) {
    return def is String ? true : (def['required'] as bool? ?? true);
  }

  bool _isPrimitive(String type) {
    return ['String', 'int', 'double', 'bool', 'DateTime'].contains(type);
  }
}
