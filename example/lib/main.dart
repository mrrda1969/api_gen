import 'dart:convert';
import 'dart:io';
import 'package:api_gen/api_gen.dart';

void main() async {
  // Load schema from api.json
  final schemaFile = File('../api.json');
  final schema =
      jsonDecode(await schemaFile.readAsString()) as Map<String, dynamic>;

  // Generate models into models/
  final generator = DartModelGenerator('models');
  generator.generate(schema);
}
