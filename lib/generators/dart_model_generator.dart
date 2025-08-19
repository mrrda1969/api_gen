import 'dart:io';

class DartModelGenerator {
  final String outputDir;

  DartModelGenerator(this.outputDir);

  void generate(Map<String, dynamic> schema) {
    Directory(outputDir).createSync(recursive: true);

    schema.forEach((modelName, fields) {
      final className = _capitalize(modelName);
      final buffer = StringBuffer();

      buffer.writeln('class $className {');

      // Fields
      (fields as Map<String, dynamic>).forEach((name, type) {
        buffer.writeln('  final ${_mapType(type)} $name;');
      });

      buffer.writeln();
      buffer.writeln('  $className({');
      fields.forEach((name, _) {
        buffer.writeln('    required this.$name,');
      });
      buffer.writeln('  });\n');

      // fromJson
      buffer.writeln(
        '  factory $className.fromJson(Map<String, dynamic> json) => $className(',
      );
      fields.forEach((name, type) {
        if (type == "double") {
          buffer.writeln("    $name: (json['$name'] as num).toDouble(),");
        } else {
          buffer.writeln("    $name: json['$name'] as ${_mapType(type)},");
        }
      });
      buffer.writeln('  );\n');

      // toJson
      buffer.writeln('  Map<String, dynamic> toJson() => {');
      fields.forEach((name, _) {
        buffer.writeln("    '$name': $name,");
      });
      buffer.writeln('  };');

      buffer.writeln('}');

      // Write file
      final file = File('$outputDir/${modelName.toLowerCase()}.dart');
      file.writeAsStringSync(buffer.toString());
    });
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  String _mapType(String type) {
    switch (type) {
      case 'int':
        return 'int';
      case 'double':
        return 'double';
      case 'string':
        return 'String';
      case 'bool':
        return 'bool';
      default:
        return 'dynamic';
    }
  }
}
