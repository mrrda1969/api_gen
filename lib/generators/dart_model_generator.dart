import 'dart:io';

import 'package:api_gen/helpers/case_helpers.dart';

class DartModelGenerator {
  final String outputDir;

  DartModelGenerator(this.outputDir);

  void generate(Map<String, dynamic> schema) {
    // Ensure the output directory exists
    final dir = Directory(outputDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    schema.forEach((className, fields) {
      final buffer = StringBuffer();

      buffer.writeln('class ${capitalize(className)} {');

      (fields as Map<String, dynamic>).forEach((name, def) {
        if (def is String) {
          final type = normalizeType(def);
          buffer.writeln('  final $type $name;');
        } else if (def is Map<String, dynamic>) {
          final type = normalizeType(def['type'] as String);
          final required = def['required'] as bool? ?? true;
          buffer.writeln('  final $type${required ? "" : "?"} $name;');
        }
      });

      buffer.writeln();
      buffer.writeln('  ${capitalize(className)}({');

      fields.forEach((name, def) {
        final required = def is String
            ? true
            : (def['required'] as bool? ?? true);
        buffer.writeln('    ${required ? "required " : ""}this.$name,');
      });

      buffer.writeln('  });');

      buffer.writeln(
        '  factory ${capitalize(className)}.fromJson(Map<String, dynamic> json) => ${capitalize(className)}(',
      );

      fields.forEach((name, def) {
        final type = def is String
            ? normalizeType(def)
            : normalizeType(def['type'] as String);
        final required = def is String
            ? true
            : (def['required'] as bool? ?? true);

        buffer.writeln(
          '    $name: json[\'$name\'] as $type${required ? "" : "?"},',
        );
      });

      buffer.writeln('  );');
      buffer.writeln();

      // toJson
      buffer.writeln('  Map<String, dynamic> toJson() => {');
      fields.forEach((name, _) {
        buffer.writeln('    \'$name\': $name,');
      });
      buffer.writeln('  };');

      buffer.writeln('}');

      // Save file
      final file = File('$outputDir/${className.toLowerCase()}.dart');
      file.writeAsStringSync(buffer.toString());
    });
  }
}
